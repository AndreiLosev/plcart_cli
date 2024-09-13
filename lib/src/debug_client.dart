import 'dart:async';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:plcart_cli/src/client.dart';
import 'package:plcart_cli/src/logger.dart';
import 'package:plcart_cli/src/tui/data_column.dart';

enum TypeTiget {
  task,
  event,
  disableTask,
  taskStart,
  eventStart,
  setTaskValue;
}

class Request {
  final TypeTiget tiget;
  final String data;

  Request(this.tiget, this.data);
}

class DebugClient {
  late final Client _client;
  final _requests = <int, Request>{};
  int _requestId = 0;
  bool verbose = false;

  final eventRx = StreamController<Message>();
  final eventTx = StreamController<SendMessage>();

  final taskRx = StreamController<Message>();
  final taskTx = StreamController<SendMessage>();

  final mainTx = StreamController<ForseValue>();
  final mainRx = StreamController<Map>();

  final consoleRx = StreamController<String>();

  final errorHandlerRx = StreamController<Object>();

  DebugClient(this._client);

  void subscribe() {
    eventTx.stream.listen((e) {
      final id = _getRequestId();
      final com =
          ClientCommand(CommandKind.runEvent, RunEventPayload(e.name, [], {}));

      _write(com, id);
      _requests[id] = Request(TypeTiget.event, e.name);
    });

    taskTx.stream.listen((e) {
      final id = _getRequestId();

      final com = switch (e.enable) {
        true => ClientCommand(
            CommandKind.subscribeTask, SimplePayload({'value': e.name})),
        false => ClientCommand(
            CommandKind.unsubscribeTask, SimplePayload({'value': e.name})),
      };
      _write(com, id);
      final type = com.kind == CommandKind.subscribeTask
          ? TypeTiget.task
          : TypeTiget.disableTask;
      _requests[id] = Request(type, e.name);
    });

    mainTx.stream.listen((e) {
      final id = _getRequestId();
      _write(
          ClientCommand(CommandKind.setTaskValue, SetTaskValuePayload(e)), id);

      _requests[id] = Request(TypeTiget.setTaskValue, e.toMap().toString());
    });
  }

  Future<void> start() async {
    var id = _getRequestId();
    _write(
      ClientCommand(CommandKind.getRegisteredTasks, null),
      id,
    );

    _requests[id] = Request(TypeTiget.taskStart, '');

    id = _getRequestId();
    _write(
      ClientCommand(CommandKind.getRegisteredEvents, null),
      id,
    );

    _requests[id] = Request(TypeTiget.eventStart, '');
  }

  Future<void> listen() async {
    while (_client.isConnected()) {
      final response = await _client.read();
      final req = _requests.remove(response.id);

      if (req == null && response.responseStatus == ResponseStatus.ok) {
        mainRx.add(response.message);
        continue;
      }

      final postfix = switch (response.responseStatus) {
        ResponseStatus.ok => 'enable',
        _ => 'desable',
      };

      if (req == null) {
        throw UnimplementedError(
            'unhadled req = null and response status error');
      }

      switch (req.tiget) {
        case TypeTiget.taskStart:
          for (var item in response.message['registeredTasks'] as List) {
            taskRx.add(Message.data(item));
          }
        case TypeTiget.eventStart:
          for (var item in response.message['registeredEvents'] as List) {
            eventRx.add(Message.data(item));
          }
        case TypeTiget.task:
          taskRx.add(Message.response("${req.data}::$postfix"));
        case TypeTiget.event:
          eventRx.add(Message.response("${req.data}::$postfix"));
        case TypeTiget.disableTask:
          taskRx.add(Message.response("${req.data}::desable"));
        case TypeTiget.setTaskValue:
        // TODO:
      }
    }
  }

  int _getRequestId() {
    _requestId += 1;

    if (_requestId >= 0xffff) {
      _requestId = 1;
      return 0;
    }

    return _requestId;
  }

  void stop() {
    eventRx.close();
    eventTx.close();
    taskRx.close();
    taskTx.close();
    mainTx.close();
    mainRx.close();
    consoleRx.close();
    _client.disconnect();
  }

  void _write(ClientCommand command, [int id = 0]) {
    flog([command.kind, command.payload]);
    try {
      _client.write(command, id);
    } catch (e) {
      errorHandlerRx.add(e);
    }
  }
}

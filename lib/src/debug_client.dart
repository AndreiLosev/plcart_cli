import 'dart:async';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:plcart_cli/src/client.dart';
import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/main_tidget.dart';

enum TypeTiget {
  task,
  event,
  taskStart,
  eventStart;
}

class Request {
  final TypeTiget tiget;
  final String data;

  Request(this.tiget, this.data);
}

class DebugClient {
  late final Client _client;
  int _statrStep = 0;
  final _requests = <int, Request>{};
  int _requestId = 0;

  final eventRx = StreamController<Message>();
  final eventTx = StreamController<SendMessage>();

  final taskRx = StreamController<Message>();
  final taskTx = StreamController<SendMessage>();

  final mainTx = StreamController<ForseValue>();
  final mainRx = StreamController<Map>();

  final consoleRx = StreamController<String>();

  DebugClient(this._client);

  void subscribe() {
    eventTx.stream.listen((e) {
      final id = _getRequestId();
      final com =
          ClientCommand(CommandKind.runEvent, RunEventPayload(e.name, [], {}));
      _client.write(com, id);
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
      _client.write(com, id);
      _requests[id] = Request(TypeTiget.task, e.name);
    });

    mainTx.stream.listen((e) {});
  }

  Future<void> start() async {
    var id = _getRequestId();
    _client.write(
      ClientCommand(CommandKind.getRegisteredTasks, null),
      id,
    );

    _requests[id] = Request(TypeTiget.taskStart, ''); 

    id = _getRequestId();
    _client.write(
      ClientCommand(CommandKind.getRegisteredEvents, null),
      id,
    );

    _requests[id] = Request(TypeTiget.eventStart, ''); 

    await Future.delayed(const Duration(seconds: 1));

    if (_requests.isEmpty && _statrStep > 2) {
      throw 'emptyStart';
    }
  }

  void listen() async {
    while (_client.isConnected()) {
      final response = await _client.read();
      final req = _requests.remove(response.id);

      if (response.responseStatus != ResponseStatus.ok) {
        consoleRx.add(response.message.toString());
      }

      if (req == null && response.responseStatus == ResponseStatus.ok) {
        mainRx.add(req as Map);
        continue;
      }

      final postfix = switch (response.responseStatus) {
        ResponseStatus.ok => 'enable',
        _ => 'desaable',
      };

      switch (req!.tiget) {
        case TypeTiget.taskStart:
          for (var item in response.message['registeredTasks'] as List) {
            taskRx.add(Message.data(item));
          }
          _statrStep += 1;
        case TypeTiget.eventStart:
          for (var item in response.message['registeredEvents'] as List) {
            eventRx.add(Message.data(item));
          }
          _statrStep += 1;
        case TypeTiget.task:
          taskRx.add(Message.response("${req.data}::$postfix"));
        case TypeTiget.event:
          eventRx.add(Message.response("${req.data}::$postfix"));
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
}

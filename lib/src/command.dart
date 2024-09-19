import 'dart:async';
import 'dart:io';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:path/path.dart';
import 'package:plcart_cli/src/client.dart';
import 'package:plcart_cli/src/debug_client.dart';
import 'package:plcart_cli/src/tui/console.dart';
import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/error_handler.dart';
import 'package:plcart_cli/src/tui/layout.dart';
import 'package:plcart_cli/src/tui/main_tidget.dart';
import 'package:plcart_cli/src/tui/tui_app.dart';
import 'package:yaml/yaml.dart';

class Command {
  static const workDirKey = "--work-dir=";
  static const hostKey = "--host=";

  late final String _workDir;
  late final String _host;

  Command(List<String> args) {
    String? workDir;
    String? host;

    workDir = _removeKey(workDirKey, args);
    host = _removeKey(hostKey, args);

    _workDir = workDir ?? Directory.current.path;
    final config = loadConfig(join(_workDir, 'pubspec.yaml'));

    _host = host ?? (config['host'] ?? "127.0.0.1");
  }

  static String? _removeKey(String key, List<String> args) {
    try {
      final val = args.firstWhere((e) => e.startsWith(key));
      return val.replaceFirst(key, "");
    } on StateError {
      return null;
    }
  }

  static Map<String, dynamic> loadConfig(path) {
    final fConfig = File(path);
    if (!fConfig.existsSync()) {
      return {};
    }

    final config = loadYaml(fConfig.readAsStringSync());

    if (config is! Map) {
      return {};
    }
    final res = config['plcart'];
    if (res is! Map) {
      return {};
    }

    return res.cast();
  }

  Future<void> debug() async {
    final soket = await Socket.connect(_host, 11223);
    final client = Client(soket);
    final debugClient = DebugClient(client);
    final events = DataColumn(name: "Events", widthIndex: true);
    final tasks = DataColumn(name: 'Tasks', widthIndex: true);
    final console = Console();
    final errorHandler = Errorhandler();

    final main = MainTidget(
      path: _workDir,
      console: console,
      errorHandler: errorHandler,
    );

    tasks.setChanels(debugClient.taskRx.stream, debugClient.taskTx.sink);
    events.setChanels(debugClient.eventRx.stream, debugClient.eventTx.sink);
    main.setChanels(debugClient.mainRx.stream, debugClient.mainTx.sink);
    errorHandler.setChanels(debugClient.errorHandlerRx.stream, null);

    final app = TuiApp()
      ..addTiget(tasks)
      ..addTiget(events)
      ..addTiget(main)
      ..addTiget(errorHandler)
      ..addRednerCallback(
          () => Layout.applay(events, tasks, main, console, errorHandler))
      ..addEndCallback(debugClient.stop);

    app.listen();
    app.render();

    debugClient.subscribe();
    await debugClient.start();
    await debugClient.listen();
  }

  Future<void> showErrors() async {
    final soket = await Socket.connect(_host, 11223);
    final client = Client(soket);
    client.write(ClientCommand(CommandKind.getAllErrors, null));
    final response = await client.read();
    switch (response.responseStatus) {
      case ResponseStatus.ok:
        (response.message['err'] as Iterable).indexed.forEach(print);
      default:
        print({'statis': response.responseStatus, 'err': response.message});
    }

    await client.disconnect();
  }
}

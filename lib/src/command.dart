import 'dart:async';
import 'dart:io';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:plcart_cli/src/client.dart';
import 'package:plcart_cli/src/config_builder.dart';
import 'package:plcart_cli/src/debug_client.dart';
import 'package:plcart_cli/src/flash_and_run.dart';
import 'package:plcart_cli/src/tui/console.dart';
import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/error_handler.dart';
import 'package:plcart_cli/src/tui/layout.dart';
import 'package:plcart_cli/src/tui/main_tidget.dart';
import 'package:plcart_cli/src/tui/tui_app.dart';

class Command {
  final _config = ConfigBuilder();
  late final FlashAndRun _flashAndRun;

  Command();

  Future<void> run(List<String> args) async {
    await _config.build(args);
    _flashAndRun = FlashAndRun(_config);
    switch (_config.command) {
      case ConfigBuilder.flashCommand:
        await _flashAndRun.flash();
      case ConfigBuilder.buildCommand:
        await _flashAndRun.build();
      case ConfigBuilder.debugCommnad:
        await debug();
      case ConfigBuilder.errorsCommad:
        await showErrors();
      default:
        help();
    }
  }

  Future<void> debug() async {
    final soket = await Socket.connect(
      _config.host,
      11223,
      timeout: _config.connTimeout,
    );
    final client = Client(soket);
    final debugClient = DebugClient(client);
    final events = DataColumn(name: "Events", widthIndex: true);
    final tasks = DataColumn(name: 'Tasks', widthIndex: true);
    final console = Console();
    final errorHandler = Errorhandler();

    final main = MainTidget(
      path: _config.workDir,
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
        () => Layout.applay(events, tasks, main, console, errorHandler),
      )
      ..addEndCallback(debugClient.stop);

    app.listen();
    app.render();

    debugClient.subscribe();
    await debugClient.start();
    await debugClient.listen();
  }

  Future<void> showErrors() async {
    final soket = await Socket.connect(
      _config.host,
      11223,
      timeout: _config.connTimeout,
    );
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

  void help() {
    print("    ");
    print("    ${ConfigBuilder.debugCommnad} - run debug mode");
    print("    ${ConfigBuilder.flashCommand} - компиояция и прошивка");
    print("    ${ConfigBuilder.buildCommand} - Компиляция");
    print("    ${ConfigBuilder.errorsCommad} - показать ошибки");
    print("    ${ConfigBuilder.helpCommand} - показать это сообщение");
    print("параметры по умолчанию: $_config");
  }
}

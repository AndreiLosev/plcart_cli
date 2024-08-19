import 'dart:async';
import 'dart:io';

import 'package:plcart_cli/src/client.dart';
import 'package:plcart_cli/src/debug_client.dart';
import 'package:plcart_cli/src/tui/console.dart';
import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/layout.dart';
import 'package:plcart_cli/src/tui/main_tidget.dart';
import 'package:plcart_cli/src/tui/tui_app.dart';

class Command {
  Future<void> debug(String host) async {
    final soket = await Socket.connect(host, 11223);
    final client = Client(soket);
    final debugClient = DebugClient(client);
    debugClient.verbose = true;
    final events = DataColumn(name: "Events", widthIndex: true);
    final tasks = DataColumn(name: 'Tasks', widthIndex: true);
    final main =
        MainTidget(path: '/home/andrei/documents/my/plcartProject/test1/');
    final console = Console();

    tasks.setChanels(debugClient.taskRx.stream, debugClient.taskTx.sink);
    events.setChanels(debugClient.eventRx.stream, debugClient.eventTx.sink);
    console.setChanels(debugClient.consoleRx.stream, null);
    main.setChanels(debugClient.mainRx.stream, debugClient.mainTx.sink);

    final app = TuiApp()
      ..addTiget(tasks)
      ..addTiget(events)
      ..addTiget(main)
      ..addTiget(console)
      ..addRednerCallback(() => Layout.applay(events, tasks, main, console))
      ..addEndCallback(debugClient.stop);

    app.listen();
    app.render();

    debugClient.subscribe();
    await debugClient.start();
    await debugClient.listen();
  }
}

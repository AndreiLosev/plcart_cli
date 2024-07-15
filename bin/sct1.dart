import 'dart:async';
import 'dart:io';

import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

void main(List<String> args) async {
  // final lib = TermLib();
  final sc = ShadowConsole();
  final f = DataColumn(
      name: 'test1', width: 10, height: 6, letf: 1, top: 1, widthINdex: true);

  final channelSend = StreamController<Message>(sync: true);
  final channelRess = StreamController<String>(sync: true);
  f.setChanels(channelSend.stream, channelRess.sink);

  f.render(sc);
  sc.comparete();
  // sc.render(lib);

  f.focuse = true;

  f.render(sc);
  sc.comparete();
  // sc.render(lib);

  channelSend.add(Message.data('wasa'));

  f.render(sc);
  sc.comparete();
  // sc.render(lib);

  channelSend.add(Message.data('igar'));

  f.render(sc);
  sc.comparete();
  // sc.render(lib);
  
  f.setKeyEvent(KeyEvent(KeyCode(name: KeyCodeName.down)));

  channelSend.add(Message.data('den1'));

  f.render(sc);
  sc.comparete();
  // sc.render(lib);

  // sleep(Duration(seconds: 5));
}

import 'dart:async';

import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termparser/termparser_events.dart';

abstract interface class ITidget {
  bool get focuse;
  set focuse(bool v);
  void render(ShadowConsole lib);
}

abstract interface class Interactive<T, A> {
  void setKeyEvent(KeyEvent event);
  void setChanels(Stream<A> rx, StreamSink<T> tx);
}

abstract interface class IFlex {
  int get innerDataWidth;
  int get innerDataHeight;
}

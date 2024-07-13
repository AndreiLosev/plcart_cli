import 'dart:async';

import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

abstract interface class ITidget {
  bool get focuse;
  set focuse(bool v);
  void render(TermLib lib);
}

abstract interface class Interactive<T, A> {
  void setKeyEvent(KeyEvent event);
  void setChanels(Stream<A> rx, StreamSink<T> tx);
}

import 'dart:async';

import 'package:plcart_cli/src/logger.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:termparser/termparser_events.dart';

class Errorhandler implements IErrorHandler, Interactive<Object, Object> {
  @override
  void addError(Object err) {
    flog({'error': err});
  }

  @override
  void setKeyEvent(KeyEvent event) {
    throw UnimplementedError();
  }

  @override
  void setChanels(Stream<Object> rx, _) {
    rx.listen((e) => flog(e));
  }
}

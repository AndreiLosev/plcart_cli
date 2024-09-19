import 'dart:async';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

final _errLabel = Style("Error !!!")..fg(Color.red);

class Errorhandler extends Frame
    implements IErrorHandler, Interactive<Object, Object> {
  Errorhandler() : super(50, 25, 5, 5);

  final _buffer = <Object>[];

  int minLeft = 10;
  int minTop = 10;
  int minWidth = 10;
  int minHeight = 10;

  int maxLeft = 10;
  int maxTop = 10;
  int maxWidth = 10;

  bool _isMinaze = true;

  @override
  void addError(Object err) {
    _buffer.add(err);
    if (_buffer.length > 50) {
      _buffer.removeRange(0, 1);
    }
  }

  @override
  void setKeyEvent(KeyEvent event) {
    switch (event.code.name) {
      case KeyCodeName.enter:
        _show();
      case KeyCodeName.escape:
        _minimaze();
      default:
    }
  }

  @override
  void setChanels(Stream<Object> rx, _) {
    rx.listen((e) {
      _buffer.add(e);
      if (_buffer.length > 50) {
        _buffer.removeRange(0, 1);
      }
    });
  }

  @override
  void render(ShadowConsole lib) {
    if (_isMinaze) {
      _minimaze();
      final text = _buffer.isNotEmpty ? _errLabel : '         ';
      lib.writeAt(contentTop(), contentLeft(), text);
      super.render(lib);
      return;
    }

    _show();
    for (var i = 0; i < _buffer.length + 5; i++) {
      lib.writeAt(top - 1 + i, left - 1, ' ' * (width + 1));
    }

    for (var (i, o) in _buffer.indexed) {
      lib.writeAt(contentTop(i), contentLeft(), o);
    }
    super.render(lib);
  }

  void _show() {
    _isMinaze = false;
    left = maxLeft;
    top = maxTop;
    width = maxWidth;
    height = _buffer.length + 2;
  }

  void _minimaze() {
    _isMinaze = true;
    left = minLeft;
    top = minTop;
    width = minWidth;
    height = minHeight;
  }
}

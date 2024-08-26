import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termparser/termparser_events.dart';

class Console extends Frame implements Interactive<dynamic, String> {
  final _buffer = <String>[];
  int _index = 0;
  int _scroll = 0;
  int? _fixStart;

  Console({
    int width = 10,
    int height = 10,
    int letf = 10,
    int top = 10,
  }) : super(width, height, letf, top);

  @override
  void setKeyEvent(KeyEvent event) {
    switch (event.code.name) {
      case KeyCodeName.down:
        if (_scroll < _buffer.length) {
          _scroll += 1;
          _fixStart = _startPos(1);
        }
      case KeyCodeName.up:
        if (_scroll > 0) {
          _scroll -= 1;
          _fixStart = _startPos(-1);
        }
      default:
    }

    if (_scroll == 0) {
      _fixStart = null;
    }
  }

  @override
  void setChanels(Stream<String> rx, _) {
    rx.listen((e) {
      _buffer.add(e);
      _nextIndex();
      if (_buffer.length > 1000) {
        _buffer.remove(_buffer.first);
      }
    });
  }

  @override
  void render(ShadowConsole lib) {
    lib.writeAt(contentTop(), contentLeft(), "hello world !!!");

    super.render(lib);
  }

  int _startPos([int add = 0]) =>
      (_buffer.length > 8 ? _buffer.length - 8 : 0) + add;

  int _nextIndex() {
    _index += 1;
    return _index;
  }
}

import 'dart:async';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class _DataSettings {
  final String name;
  bool focuse = false;
  bool active = false;

  _DataSettings(this.name);
}

abstract class DataColumn<A> extends Frame implements Interactive<String ,A> {
  final _data = <_DataSettings>[];
  late final StreamSink<String> _tx;

  DataColumn(super.width, super.height, super.letf, super.top);

  @override
  void setKeyEvent(KeyEvent event) {
    switch ((event.code.name, _data.isNotEmpty)) {
      case (KeyCodeName.up, true):
        final index = _getFocusedElementIndex();
        _data[index].focuse = false;
        final newIndex = switch (index) {
          0 => _data.length - 1,
          _ => index - 1,
        };
        _data[newIndex].focuse = true;

      case (KeyCodeName.down, true):
        final index = _getFocusedElementIndex();
        _data[index].focuse = false;
        final newIndex = (index + 1) % _data.length;
        _data[newIndex].focuse = true;

      case (KeyCodeName.enter, true):
        final index = _getFocusedElementIndex();
        _tx.add(_data[index].name);
        _data[index].active = true;
      default:
    }
  }

  @override
  void render(TermLib lib) {
    super.render(lib);
    for (var i = 0; i < _data.length; i++) {
      final content = Style(_data[i].name);

      if (_data[i].active) {
        content.fg(Color.brightMagenta);
        content.bg(Color.cyan);
      }
      if (_data[i].focuse) {
        content.reverse();
      }

      lib.writeAt(contentTop() + i + 1, contentLeft(), _data[i].name);
    }
  }

  int _getFocusedElementIndex() {
    for (var i = 0; i < _data.length; i++) {
      if (_data[i].focuse) {
        return i;
      }
    }

    return 0;
  }
}

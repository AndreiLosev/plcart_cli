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

enum DataType {
  setData,
  response,
}

class Message {
  final DataType type;
  final String data;

  Message.data(this.data) : type = DataType.setData;
  Message.response(this.data) : type = DataType.response;
}

class DataColumn extends Frame implements Interactive<String, Message>, IFlex {
  final _data = <_DataSettings>[];
  late final StreamSink<String> _tx;
  late final String _name;
  int _scroll = 0;
  int _lastRenderIndex = 0;

  DataColumn(String name, super.width, super.height, super.letf, super.top) {
    _name = " $name ";
  }

  @override
  void setChanels(Stream<Message> rx, StreamSink<String> tx) {
    _tx = tx;
    rx.listen((e) {
      switch (e.type) {
        case DataType.setData:
          _data.add(_DataSettings(e.data));
          if (_data.length == 1) {
            _data.first.focuse = true;
          }
        case DataType.response:
          for (var item in _data) {
            item.active = false;
          }
      }
    });
  }

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
  int contentTop([int add = 0]) {
    return super.contentTop(add + 1);
  }

  @override
  int contentHeight([int add = 0]) {
    return super.contentHeight(add - 1);
  }

  @override
  void render(TermLib lib) {
    super.render(lib);

    _renderTitle(lib);

    for (var i = _scroll; i < _data.length; i++) {
      final content = Style(_data[i].name);

      if (_data[i].active) {
        content
          ..fg(Color.brightBlue)
          ..bold();
      }
      if (_data[i].focuse) {
        content.reverse();
      }

      if (contentHeight() < (i + _scroll)) {
        _lastRenderIndex = i - 1;
        return;
      }

      lib.writeAt(contentTop() + i, contentLeft(), content);
    }

    _lastRenderIndex = _data.length - 1;
  }

  @override
  int contentLen() {
    int max = _name.length;

    for (var i in _data) {
      if (i.name.length > max) {
        max = i.name.length;
      }
    }

    return max;
  }

  void handleScroll(KeyCodeName code) {
    switch (code) {
      case KeyCodeName.up:
        if (_scroll == _getFocusedElementIndex()) {
          _scroll -= 1;
        }
      case KeyCodeName.down:
        if (_lastRenderIndex == _getFocusedElementIndex()) {
          _scroll += 1;
        }
      default:
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

  void _renderTitle(TermLib lib) {
    final addWiteSpace =  ' ' * ((width - _name.length - 4) / 2).round();
    final prittyText = "$addWiteSpace$_name$addWiteSpace${width % 2 == 0 ? '' : ' '}"; 
    final style = switch (super.focuse) {
      true => Style(prittyText)
        ..bold()
        ..underline()
        ..bg(Color.green)
        ..fg(Color.black),
      false => Style(prittyText)
        ..bold()
        ..underline(),
    };

    lib.writeAt(
      super.contentTop(),
      contentLeft(),
      style,
    );
  }
}

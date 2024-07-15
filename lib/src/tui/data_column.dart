import 'dart:async';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
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
  // int _lastRenderIndex = 0;
  final bool _widthINdex;

  DataColumn(
      {required String name,
      required int width,
      required int height,
      required int letf,
      required int top,
      widthINdex = false})
      : _widthINdex = widthINdex,
        super(width, height, letf, top) {
    _name = " $name ";
  }

  @override
  set focuse(bool focuse) {
    switch ((focuse, _data.length)) {
      case (false, != 0):
        _data[_getFocusedElementIndex()].focuse = false;
      case (true, != 0):
        _data[0].focuse = true;
    }
    super.focuse = focuse;
  }

  @override
  void setChanels(Stream<Message> rx, StreamSink<String> tx) {
    _tx = tx;
    rx.listen((e) {
      switch (e.type) {
        case DataType.setData:
          _data.add(_DataSettings(e.data));
          if (_data.length == 1 && super.focuse) {
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
        _scrollDownIfNeeded();

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
  void render(ShadowConsole lib) {
    super.render(lib);

    _renderTitle(lib);

    for (var i = _scroll; i < _data.length; i++) {
      final content =
          Style(_widthINdex ? "$i. ${_data[i].name}" : _data[i].name);

      if (_data[i].active) {
        content
          ..fg(Color.brightBlue)
          ..bold();
      }
      if (_data[i].focuse) {
        content.reverse();
      }

      if (i > contentHeight(_scroll)) {
        return;
      }

      lib.writeAt(contentTop(i - _scroll), contentLeft(), content);
    }
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

  void _scrollDownIfNeeded() {
    final index = _getFocusedElementIndex();
    if (index == 0) {
      _scroll = 0;
    }
    if (index > contentHeight(_scroll)) {
      _scroll += 1;
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

  void _renderTitle(ShadowConsole lib) {
    final addWiteSpace = ' ' * ((width - _name.length - 4) / 2).round();
    final prittyText =
        "$addWiteSpace$_name$addWiteSpace${width % 2 == 0 ? '' : ' '}";
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

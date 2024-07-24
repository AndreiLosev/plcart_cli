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

class SendMessage {
  final bool enable;
  final String name;

  SendMessage(this.enable, this.name);

  @override
  String toString() {
    return {'enable': enable, 'name': name}.toString();
  }
}

class DataColumn extends Frame
    implements Interactive<SendMessage, Message>, IFlex {
  final _data = <_DataSettings>[];
  late final StreamSink<SendMessage> _tx;
  late final String _name;
  int _scroll = 0;
  final bool _widthIndex;

  DataColumn(
      {required String name,
      int width = 10,
      int height = 10,
      int letf = 10,
      int top = 10,
      widthIndex = false})
      : _widthIndex = widthIndex,
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
  int get innerDataWidth {
    int res = _data.fold(0, (a, e) => e.name.length > a ? e.name.length : a);
    return res + (_widthIndex ? 3 : 0) + 4;
  }

  @override
  int get innerDataHeight => _data.length + 1 + (height - contentHeight()) * 2;

  @override
  void setChanels(Stream<Message> rx, StreamSink<SendMessage>? tx) {
    _tx = tx!;
    rx.listen((e) {
      switch (e.type) {
        case DataType.setData:
          _data.add(_DataSettings(e.data));
          if (_data.length == 1 && super.focuse) {
            _data.first.focuse = true;
          }
        case DataType.response:
          final [name, action] = e.data.split('::');
          for (var item in _data) {
            if (item.name == name) {
              item.active = action == 'enable';
            }
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
        _scrollUpIfNeeded();

      case (KeyCodeName.down, true):
        final index = _getFocusedElementIndex();
        _data[index].focuse = false;
        final newIndex = (index + 1) % _data.length;
        _data[newIndex].focuse = true;
        _scrollDownIfNeeded();

      case (KeyCodeName.enter, true):
        final index = _getFocusedElementIndex();
        _tx.add(SendMessage(!_data[index].active, _data[index].name));
        _data[index].active = !_data[index].active;

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
          Style(_widthIndex ? "$i. ${_data[i].name}" : _data[i].name);

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

  void _scrollUpIfNeeded() {
    final index = _getFocusedElementIndex();
    if (index == (_data.length - 1)) {
      if ((_data.length - 1) > contentHeight()) {
        _scroll = (_data.length - 1) - contentHeight();
      }
    }
    if (index < _scroll) {
      _scroll -= 1;
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

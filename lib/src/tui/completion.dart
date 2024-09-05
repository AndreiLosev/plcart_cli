import 'dart:async';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class Completion extends Frame
    implements Interactive<String, Iterable<String>> {
  Iterable<String> _fields = Iterable.empty();
  Iterable<String> _filteredFirelds = Iterable.empty();
  int _cursore = 0;
  late final StreamSink<String> _tx;

  Completion() : super(0, 0, 0, 0) {
    super.focuse = true;
  }

  @override
  void setKeyEvent(KeyEvent event) {
    switch (event.code.name) {
      case KeyCodeName.tab:
        _cursore = (_cursore + 1) % _filteredFirelds.length;
      case KeyCodeName.enter:
        for (var (i, field) in _filteredFirelds.indexed) {
          if (i == _cursore) {
            _tx.add(field);
            return;
          }
        }
      default:
    }
  }

  @override
  void setChanels(Stream<Iterable<String>> rx, StreamSink<String>? tx) {
    rx.listen((e) => _fields = e);
    _tx = tx!;
  }

  bool preparationRender(int left, int top, String filter) {
    if (_fields.isEmpty) {
      return false;
    }

    _filteredFirelds = _fields.where((f) => f.startsWith(filter));

    if (_filteredFirelds.isEmpty) {
      return false;
    }

    if (_filteredFirelds.length == 1 && _filteredFirelds.first == filter) {
      return false;
    }

    this.left = left;
    width = _filteredFirelds.fold(0, (a, b) => a > b.length ? a : b.length) + 3;
    height = _filteredFirelds.length + 1;
    this.top = top - height;

    return true;
  }

  @override
  void render(ShadowConsole lib) {
    for (var (i, field) in _filteredFirelds.indexed) {
      final text = switch (i == _cursore) {
        true => Style(field)..reverse(),
        false => field
      };
      lib.writeAt(
        contentTop(i),
        contentLeft(),
        text,
      );
    }

    super.render(lib);
  }
}

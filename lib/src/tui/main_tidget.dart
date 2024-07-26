import 'dart:async';
import 'dart:ffi';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class ForseValue {}

class MainTidget extends Frame implements Interactive<ForseValue, Map> {
  late final StreamSink<ForseValue> _tx;
  Map? _buffer;

  MainTidget({
    int width = 30,
    int height = 30,
    int letf = 10,
    int top = 10,
  }) : super(width, height, letf, top);

  @override
  void setKeyEvent(KeyEvent event) {}

  @override
  void setChanels(Stream<Map> rx, StreamSink<ForseValue>? tx) {
    _tx = tx!;

    rx.listen((e) {
      _buffer = e.cast();
    });
  }

  @override
  void render(ShadowConsole lib) {
    super.render(lib);
    if (_buffer == null) {
      return;
    }

    int top = 0;
    for (final MapEntry(key: taskName, value: fields) in _buffer!.entries) {
      final s = Style("$taskName:")
        ..bold()
        ..fg(Color.blue)
        ..underline();
      lib.writeAt(contentTop(top), contentLeft(2), s);
      for (final (int i, MapEntry(key: name, value: value))
          in (fields as Map).entries.indexed) {
        final nameLen = (name as String).length;
        final sn = Style("$name:")..fg(Color.brightYellow);
        lib.writeAt(contentTop(1 + i + top), contentLeft(4), sn);
        lib.writeAt(contentTop(1 + i + top), contentLeft(6 + nameLen), _styledValue(value));
      }
      top += fields.length + 1;
    }
  }

  Object _styledValue(value) {
    return switch (value) {
      bool() => Style(value.toString())..fg(Color.red),
      int() => Style(value.toString())..fg(Color.cyan),
      double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
      String() => Style("'$value'")..fg(Color.green),
      Iterable() => value.map(_styledValue),
      Map() => Map.fromEntries(value.entries
          .map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value)))),
      _ => value,
    };
  }
}

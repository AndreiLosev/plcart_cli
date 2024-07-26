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
  final _buffer = StringBuffer();

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
      _buffer.clear();
      for (final MapEntry(key: taskName, value: fields) in e.entries) {
        final s = Style("$taskName:")
          ..bold()
          ..fg(Color('81'))
          ..underline();
        _buffer.writeln("  $s");
        _setTaskFieds(fields);
      }
    });
  }

  void _setTaskFieds(Map fields) {
    for (final MapEntry(key: name, value: value) in fields.entries) {
      final sn = Style("$name")..fg(Color.brightYellow);
      final sv = _styledValue(value);
      _buffer.writeln("    $sn: $sv");
    }
  }

  @override
  void render(ShadowConsole lib) {
    super.render(lib);
    if (_buffer.isEmpty) {
      return;
    }

    lib.writeAt(contentTop(), contentLeft(), _buffer.toString());
  }

  Object _styledValue(value) {
    return switch (value) {
      bool() => Style(value.toString())..fg(Color.red),
      int() => Style(value.toString())..fg(Color.cyan),
      double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
      String() => Style("'$value'")..fg(Color.green),
      Iterable() => _styledIterable(value),
      Map() => _styledMap(value),
      _ => value,
    };
  }

  Iterable _styledIterable(Iterable it) {
    if (it.length > 10) {
      return it.take(10).map(_styledValue).toList()..add('...');
    }

    return it.map(_styledValue).toList();
  }

  Map _styledMap(Map m) {
    final im = m.entries;
    if (im.length > 10) {
      final rm = Map.fromEntries(im
          .take(10)
          .map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value))));
      rm[''] = ['...'];

      return rm;
    }

    return Map.fromEntries(
        im.map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value))));
  }
}

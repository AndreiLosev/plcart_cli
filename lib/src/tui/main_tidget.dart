import 'dart:async';
import 'dart:io';

import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/colorist.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/grep.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class ForseValue {}

class MainTidget extends Frame implements Interactive<ForseValue, Map> {
  late final StreamSink<ForseValue> _tx;
  final _buffer = StringBuffer();
  final Grep _grep;
  final _colorist = Colorist();
  int _midline = 0;

  MainTidget({
    int width = 30,
    int height = 30,
    int letf = 10,
    int top = 10,
    required String path,
  })  : _grep = Grep(path),
        super(width, height, letf, top);

  @override
  void setKeyEvent(KeyEvent event) {
    //TODO:
    UnimplementedError();
    _tx.add(ForseValue());
  }

  @override
  void setChanels(Stream<Map> rx, StreamSink<ForseValue>? tx) {
    _tx = tx!;

    rx.listen((e) async {
      _buffer.clear();
      Map? f1;
      for (final MapEntry(key: taskName, value: fields) in e.entries) {
        f1 ??= fields[1];
        final s = Style("$taskName:")
          ..bold()
          ..fg(Color('81'))
          ..underline();
        _buffer.writeln("  $s");
        if (_colorist.isSubtipe(fields)) {
          _buffer.writeln(_colorist.setTaskFieds(fields[1]));
        } else {
          _buffer.writeln(_colorist.setTaskFieds(fields));
        }
      }

      _buffer.writeln("____________\n");
      _buffer.writeln(
        _colorist.paintSrc(e.keys.firstOrNull,
            await _grep.search(e.keys.firstOrNull), f1!.cast()),
      );
    });
  }

  @override
  void render(ShadowConsole lib) {
    super.render(lib);
    _renderMiline(lib);
    if (_buffer.isEmpty) {
      return;
    }

    for (var (i, e) in _bufferPreparation().indexed) {
      lib.writeAt(contentTop(i), contentLeft(), e);
    }
  }

  List<String> _bufferPreparation() {
    return _buffer
        .toString()
        .split(Platform.lineTerminator)
        .take(contentWidth())
        .toList();
  }

  void _renderMiline(ShadowConsole lib) {
    _midline = (super.letf + super.width) ~/ 2;
    for (var i = 0; i < super.height - 1; i++) {
      lib.writeAt(top + i + 1, _midline, "|>");
    }
  }
}

import 'dart:async';

import 'package:plcart_cli/src/tui/colorist.dart';
import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/grep.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class ForseValue {}

class MainTidget extends Frame implements Interactive<ForseValue, Map> {
  late final StreamSink<ForseValue> _tx;
  final _buffer = StringBuffer();
  final Grep _grep;
  final _colorist = Colorist();

  MainTidget({
    int width = 30,
    int height = 30,
    int letf = 10,
    int top = 10,
    required String path,
  })  : _grep = Grep(path),
        super(width, height, letf, top);

  @override
  void setKeyEvent(KeyEvent event) {}

  @override
  void setChanels(Stream<Map> rx, StreamSink<ForseValue>? tx) {
    _tx = tx!;

    rx.listen((e) async {
      _buffer.clear();

      for (final MapEntry(key: taskName, value: fields) in e.entries) {
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
        _colorist.paintMethods(
            e.keys.firstOrNull, await _grep.search(e.keys.firstOrNull)),
      );
    });
  }

  @override
  void render(ShadowConsole lib) {
    super.render(lib);
    if (_buffer.isEmpty) {
      return;
    }

    lib.writeAt(contentTop(), contentLeft(), _buffer.toString());
  }
}

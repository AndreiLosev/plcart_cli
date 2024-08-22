import 'dart:async';
import 'dart:io';

import 'package:plcart_cli/src/logger.dart';
import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/colorist.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/grep.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class ForseValue {}

enum Screen {
  left,
  right;
}

class MainTidget extends Frame implements Interactive<ForseValue, Map> {
  late final StreamSink<ForseValue> _tx;
  final _fieldsBuff = StringBuffer();
  final _sourceBuff = StringBuffer();
  final Grep _grep;
  final _colorist = Colorist();
  final _searcher = StyleSearcher();
  final _selectedChar = Style(">>")
    ..bold()
    ..fg(Color.cyan);

  Screen _screen = Screen.left;
  int _midline = 0;
  int _cursorePosition = 0;
  int _activeTask = 0;
  int _positionMax = 0;

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
    switch (event.code.name) {
      case KeyCodeName.up:
        _cursorePosition--;
        if ((_cursorePosition) < 0) {
          _cursorePosition = 0;
        }
      case KeyCodeName.down:
        _cursorePosition++;
        if ((_cursorePosition) >= _positionMax) {
          _cursorePosition = _positionMax - 1;
        }
      case KeyCodeName.enter:
        _activeTask = _cursorePosition;
      default:
    }

    _tx.add(ForseValue());
  }

  @override
  void setChanels(Stream<Map> rx, StreamSink<ForseValue>? tx) {
    _tx = tx!;

    rx.listen(_listen);
  }

  @override
  void render(ShadowConsole lib) {
    super.render(lib);
    _renderMiline(lib);
    if (_fieldsBuff.isEmpty) {
      return;
    }

    _renderBuffers(lib, _fieldsBuff, contentLeft(-1));
    _renderBuffers(lib, _sourceBuff, _midline + 1);
  }

  List<String> _bufferPreparation(StringBuffer buff) {
    return buff
        .toString()
        .split(Platform.lineTerminator)
        .take(contentHeight())
        .toList();
  }

  void _renderBuffers(ShadowConsole lib, StringBuffer buff, int left) {
    final width = _midline - 1;
    for (var (i, e) in _bufferPreparation(buff).indexed) {
      final text = switch (width > e.length) {
        true => e,
        false => _substringStyled(e, width),
      };
      lib.writeAt(contentTop(i), left, text);
    }
  }

  void _renderMiline(ShadowConsole lib) {
    _midline = (super.letf + super.width) ~/ 2;
    for (var i = 0; i < super.height - 1; i++) {
      lib.writeAt(top + i + 1, _midline, "│");
    }
  }

  (String, String, Map<String, dynamic>) _current(Map e) {
    final keys = e.keys.toList();
    final String activeTask = keys[_activeTask];
    final String selectedTask = keys[_cursorePosition];
    final Map<String, dynamic> taskFields = {};
    for (MapEntry item in e[activeTask][1].entries) {
      taskFields[item.key] = item.value;
    }

    return (selectedTask, activeTask, taskFields);
  }

  String _substringStyled(String s, int end) {
    int length = 0;

    final result = _searcher
        .search(s)
        .where((e) {
          length += e.text.length;
          return length < end;
        })
        .map((e) => e.toString())
        .join();

    return switch (s.length - result.length > 2) {
      true => "$result ...",
      false => result,
    };
  }

  void _setExtroCursorPosition(Map e) {
    _positionMax = e.keys.length;
    if (_positionMax < (_cursorePosition - 1)) {
      _cursorePosition = _positionMax - 1;
    }
    if (_positionMax == 0) {
      _cursorePosition = 0;
    }
  }

  void _listen(e) async {
    _fieldsBuff.clear();
    _sourceBuff.clear();

    _setExtroCursorPosition(e);
    final (selectedTask, activeTask, taskFields) = _current(e);
    for (final MapEntry(key: taskName, value: fields) in e.entries) {
      _fieldsBuff.writeln(_paintActiveTask(selectedTask, activeTask, taskName));
      if (_colorist.isSubtipe(fields)) {
        _fieldsBuff.writeln(_colorist.setTaskFieds(fields[1]));
      } else {
        _fieldsBuff.writeln(_colorist.setTaskFieds(fields));
      }
    }
    _sourceBuff.writeln(
      _colorist.paintSrc(
          activeTask, await _grep.search(activeTask), taskFields),
    );
  }

  String _paintActiveTask(
    String selectedTask,
    String activeTask,
    String taskName,
  ) {
    var s = Style(activeTask == taskName ? "$taskName:   @src" : "$taskName:")
      ..bold()
      ..fg(Color('81'))
      ..underline();

    if (selectedTask == taskName) {
      s.reverse();
      return "$_selectedChar $s";
    }

    return "  $s";
  }
}

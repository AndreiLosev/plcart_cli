import 'dart:async';
import 'dart:io';

import 'package:plcart_cli/src/tui/console.dart';
import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/colorist.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/forse_value.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/grep.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/helpers.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

final _midlineLeft = "${Style("│")..fg(Color.green)}│";
final _midlineRight = "│${Style("│")..fg(Color.green)}";
final _disabled = "││";

enum Screen {
  left,
  right;

  String value(bool active) => switch ((active, this)) {
        (true, Screen.left) => _midlineLeft,
        (true, Screen.right) => _midlineRight,
        _ => _disabled,
      };

  void leftCursore(Style s) {
    switch (this) {
      case Screen.left:
        s.reverse();
      case Screen.right:
    }
  }
}

class MainTidget extends Frame implements Interactive<ForseValue, Map> {
  final Console _console;
  final _consoleStream = StreamController<Iterable<String>>();
  late final StreamSink<ForseValue> _tx;
  final _fieldsBuff = StringBuffer();
  final _sourceBuff = StringBuffer();
  final Grep _grep;
  final _colorist = Colorist();
  final _searcher = StyleSearcher();
  final _selectedChar = (Style(">>")
        ..bold()
        ..fg(Color.cyan))
      .toString();

  Screen _screen = Screen.left;
  int _midline = 0;
  int _cursorePosition = 0;
  int _activeTask = 0;
  int _positionMax = 0;
  List<String> _tasks = [];
  List<String> _taskFields = [];
  int _srcScroll = 0;

  MainTidget({
    int width = 30,
    int height = 30,
    int letf = 10,
    int top = 10,
    required String path,
    required Console console,
  })  : _grep = Grep(path),
        _console = console,
        super(width, height, letf, top) {
    _console.setChanels(_consoleStream.stream, null);
  }

  @override
  void setKeyEvent(KeyEvent event) {
    switch ((event.code.name, _screen, _console.focuse, event.code.char)) {
      case (KeyCodeName.up, Screen.left, false, ''):
        _cursorePosition--;
        if ((_cursorePosition) < 0) {
          _cursorePosition = 0;
        }
      case (KeyCodeName.down, Screen.left, false, ''):
        _cursorePosition++;
        if ((_cursorePosition) >= _positionMax) {
          _cursorePosition = _positionMax - 1;
        }
      case (KeyCodeName.enter, Screen.left, false, ''):
        _activeTask = _cursorePosition;
      case (KeyCodeName.up, Screen.right, false, ''):
        if (_srcScroll > 0) {
          _srcScroll--;
        }
      case (KeyCodeName.down, Screen.right, false, ''):
        _srcScroll++;
      case (KeyCodeName.left, _, false, ''):
        _screen = Screen.left;
      case (KeyCodeName.right, _, false, ''):
        _screen = Screen.right;
      case (KeyCodeName.escape, Screen.left, true, ''):
        _console.focuse = false;
        _console.clear();
      case (_, Screen.left, false, 'e'):
        _console.focuse = true;
        _consoleStream.add(_taskFields);
      case (_, Screen.left, true, _):
        _console.setKeyEvent(event);
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
    if (_fieldsBuff.isEmpty) {
      return;
    }

    _renderBuffers(lib, _fieldsBufferPreparation(), contentLeft(-1));
    _renderBuffers(lib, _srcBufferPreparation(), _midline + 1);
    _renderMidline(lib);
    _console.render(lib);
  }

  Iterable<String> _fieldsBufferPreparation() {
    int cursoreLine = 0;
    final lines = _fieldsBuff.toString().split(Platform.lineTerminator);

    for (var (i, line) in lines.indexed) {
      if (line.trim().startsWith(_selectedChar)) {
        cursoreLine = i;
        break;
      }
    }

    int scroll = cursoreLine - contentHeight();
    if (scroll < 0) {
      scroll = 0;
    }

    if (scroll > 0) {
      try {
        final nextTask = _tasks[_cursorePosition + 1];
        for (var (i, line) in lines.skip(cursoreLine).indexed) {
          if (line.trim().contains(nextTask)) {
            scroll += i;
            break;
          }
        }
      } on RangeError {
        return lines.skip(lines.length - contentHeight() - 3);
      }
    }

    return lines.skip(scroll).take(contentHeight());
  }

  Iterable<String> _srcBufferPreparation() {
    final lines = _sourceBuff.toString().split(Platform.lineTerminator);
    if ((lines.length - 3) < _srcScroll) {
      _srcScroll = lines.length - 3;
    }

    try {
      return lines.skip(_srcScroll).take(contentHeight());
    } on RangeError {
      return lines;
    }
  }

  void _renderBuffers(ShadowConsole lib, Iterable<String> buff, int left) {
    final width = _midline - 1;
    for (var (i, e) in buff.indexed) {
      final text = switch (width > e.length) {
        true => e,
        false => _substringStyled(e, width),
      };
      lib.writeAt(contentTop(i), left, text);
    }
  }

  void _renderMidline(ShadowConsole lib) {
    _midline = (super.left + super.width) ~/ 2 - 2;
    for (var i = 0; i < super.height - 1; i++) {
      lib.writeAt(top + i + 1, _midline, _screen.value(focuse));
    }
  }

  (String, String, Map<String, dynamic>) _current(Map e) {
    if (_activeTask >= _tasks.length) {
      _activeTask = _tasks.length - 1;
    }
    final String activeTask = _tasks[_activeTask];
    if (_cursorePosition >= _tasks.length) {
      _cursorePosition = _tasks.length - 1;
    }
    final String selectedTask = _tasks[_cursorePosition];
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
    _tasks = (e as Map).keys.cast<String>().toList();
    final (selectedTask, activeTask, taskFields) = _current(e);
    _taskFields = (e[selectedTask][1] as Map).keys.toList().cast();
    for (final MapEntry(key: taskName, value: fields) in e.entries) {
      _fieldsBuff.writeln(_paintActiveTask(selectedTask, activeTask, taskName));
      if (isSubtipe(fields)) {
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
      _screen.leftCursore(s);
      return "$_selectedChar $s";
    }

    return "  $s";
  }
}

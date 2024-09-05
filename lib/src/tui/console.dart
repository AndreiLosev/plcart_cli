import 'dart:async';

import 'package:plcart_cli/src/tui/completion.dart';
import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

// const _carriage = '|';
final _carriage = Style('|')
  ..fg(Color.brightBlue)
  ..bold();

class Console extends Frame implements Interactive<String, Iterable<String>> {
  final _completionFields = Completion();
  final _completionFieldsRx = StreamController<Iterable<String>>();
  final _completionFieldsTx = StreamController<String>();
  final _buffer = <String>[];
  int _carriagePosition = 0;

  Console({
    int width = 10,
    int height = 10,
    int letf = 10,
    int top = 10,
  }) : super(width, height, letf, top) {
    _completionFields.setChanels(
        _completionFieldsRx.stream, _completionFieldsTx.sink);

    _completionFieldsTx.stream.listen((e) {
      _buffer.clear();
      for (var i = 0; i < e.length; i++) {
        _buffer.add(e[i]);
      }
      _carriagePosition = _buffer.length;
    });
  }

  @override
  void setKeyEvent(KeyEvent event) {
    if (event.code.char != '') {
      _addChar(event.code.char);
      return;
    }
    switch (event.code.name) {
      case KeyCodeName.backSpace:
        _removeChar(true);
      case KeyCodeName.delete:
        _removeChar(false);
      case KeyCodeName.left:
        if (_carriagePosition > 0) {
          _carriagePosition -= 1;
        }
      case KeyCodeName.right:
        if (_carriagePosition < _buffer.length) {
          _carriagePosition += 1;
        }
      case (KeyCodeName.tab || KeyCodeName.enter):
        _completionFields.setKeyEvent(event);
      default:
    }
  }

  void clear() {
    _buffer.clear();
    _carriagePosition = 0;
  }

  void _addChar(String newCahr) {
    try {
      if (_buffer.isEmpty) {
        _buffer.add(newCahr);
        return;
      }

      _buffer.add('');
      final (start, end) = _getStartAndEnd();
      _buffer.setRange(0, _buffer.length, [...start, newCahr, ...end]);
    } finally {
      _carriagePosition += 1;
    }
  }

  void _removeChar(bool isBackSpace) {
    final (start, end) = _getStartAndEnd();
    if (start.isEmpty && isBackSpace) {
      return;
    }

    if (end.isEmpty && !isBackSpace) {
      return;
    }

    final (newStart, newEnd) = switch (isBackSpace) {
      true => (start.take(start.length - 1), end),
      false => (start, end.skip(1)),
    };

    _buffer.setRange(0, _buffer.length - 1, [
      ...newStart,
      ...newEnd,
    ]);

    _buffer.removeLast();

    if (isBackSpace) {
      _carriagePosition--;
    }
  }

  @override
  void setChanels(Stream<Iterable<String>> rx, _) {
    _completionFieldsRx.addStream(rx);
  }

  @override
  void render(ShadowConsole lib) {
    final (start, end) = _getStartAndEnd();
    lib.writeAt(
      contentTop(),
      contentLeft(),
      "${start.join()}$_carriage${end.join()}",
    );

    super.render(lib);

    if (_buffer.isEmpty || !focuse) {
      return;
    }

    if (_completionFields.preparationRender(
      contentLeft(),
      top,
      _buffer.join(),
    )) {
      _completionFields.render(lib);
    }
  }

  (Iterable<String>, Iterable<String>) _getStartAndEnd() {
    final start = _buffer.take(_carriagePosition);
    final end = _buffer.getRange(_carriagePosition, _buffer.length);

    return (start, end);
  }
}

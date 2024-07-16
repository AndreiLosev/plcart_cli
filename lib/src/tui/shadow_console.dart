import 'dart:io';

import 'package:termlib/termlib.dart';

class ShadowConsole {
  final List<List<String>> _console = [];
  final List<List<String>> _newConsole = [];
  final _renderBuffer = <(int row, int col, Object s)>[];

  ShadowConsole() {
    final width = stdout.terminalColumns;
    final hieght = stdout.terminalLines;

    // final width = 14;
    // final hieght = 8;

    for (var i = 0; i < hieght; i++) {
      final row = <String>[];
      final newRow = <String>[];
      for (var j = 0; j < width; j++) {
        row.add(' ');
        newRow.add(' ');
      }
      _console.add(row);
      _newConsole.add(newRow);
    }
  }

  void writeAt(int row, int col, Object s) {
    if (row > _newConsole.length || col > _newConsole[row].length) {
      return;
    }
    final arrText = _asTerminal(s);
    for (var (j, line) in arrText.indexed) {
      for (var (i, char) in line.indexed) {
        _newConsole[row + j][col + i] = char;
      }
    }
  }

  void comparete() {
    for (var i = 0; i < _newConsole.length; i++) {
      for (var j = 0; j < _newConsole[i].length; j++) {
        if (_console[i][j] != _newConsole[i][j]) {
          _renderBuffer.add((i, j, _newConsole[i][j]));
          _console[i][j] = _newConsole[i][j];
        }
      }
    }

    for (var i = 0; i < _newConsole.length; i++) {
      for (var j = 1; j < _newConsole[i].length; j++) {
        _newConsole[i][j] = ' ';
      }
    }
  }

  void render(TermLib lib) {
    for (var (i, j, s) in _renderBuffer) {
      lib.writeAt(i, j, s);
    }

    _renderBuffer.clear();
  }

  static Iterable<Iterable<String>> _asTerminal(Object s) {
    final text = s.toString();
    switch (s) {
      case Style():
        final p = text.replaceFirst(s.text, '   ');
        final [start, end] = p.split('   ');
        final result = <List<String>>[];
        for (var line in s.text.split(Platform.lineTerminator)) {
          result.add([]);
          for (var i = 0; i < line.length; i++) {
            result.last.add("$start${line[i]}$end");
          }
        }

        return result;
      default:
        final result = <List<String>>[];
        for (var line in text.split(Platform.lineTerminator)) {
          result.add([]);
          for (var i = 0; i < line.length; i++) {
            result.last.add(line[i]);
          }
        }

        return result;
    }
  }
}

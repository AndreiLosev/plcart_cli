import 'dart:io';

import 'package:termlib/termlib.dart';

class ShadowConsole {
  final List<List<String>> _console = [];
  final List<List<String>> _newConsole = [];
  final _renderBuffer = <(int row, int col, Object s)>[];

  ShadowConsole() {
    final width = stdout.terminalColumns;
    final hieght = stdout.terminalLines;

    // final width = 10;
    // final hieght = 6;

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
    final text = s.toString();
    if (row > _newConsole.length || col > _newConsole[row].length) {
      return;
    }
    // for (var i = 0; i < text.length; i++) {
    //   _newConsole[row][col + i] = text[i];
    // }
    _newConsole[row][col] = text;
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
      for (var j = 0; j < _newConsole[i].length; j++) {
        if (_newConsole[i][j] != ' ') {
          _newConsole[i][j] = ' ' * _newConsole[i][j].length;
        }
      }
    }
  }

  void render(TermLib lib) {
    for (var (i, j, s) in _renderBuffer) {
      lib.writeAt(i, j, s);
    }

    _renderBuffer.clear();
  }
}

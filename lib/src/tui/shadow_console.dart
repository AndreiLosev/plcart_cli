import 'dart:io';

import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';

class ShadowConsole {
  final List<List<String>> _console = [];
  final List<List<String>> _newConsole = [];
  final _renderBuffer = <(int row, int col, Object s)>[];
  final _searcher = StyleSearcher();

  ShadowConsole() {
    final width = stdout.terminalColumns;
    final hieght = stdout.terminalLines;

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
    if (row > (_newConsole.length - 1) || col > (_newConsole[row].length - 1)) {
      return;
    }

    final styledChars = _searcher
        .search(s.toString())
        .map((e) => e.toStyledChars())
        .expand((x) => x)
        .toList();
    
    int i = 0;
    for (var char in styledChars) {
      if ((row) > (_newConsole.length - 1) ||
          (col + i) > (_newConsole[row].length - 1)) {
        return;
      }

      if (char.contains(Platform.lineTerminator)) {
        row += 1;
        i = 0;
      }
      _newConsole[row][col + i] = char;
      i++;
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
}

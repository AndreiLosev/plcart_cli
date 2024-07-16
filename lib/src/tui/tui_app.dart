import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class TuiApp {
  final _lib = TermLib();
  final _shadowConsole = ShadowConsole();
  final _tigets = <ITidget>[];
  final _interactive = <Interactive>[];
  bool _run = true;
  final _debugConsole = Queue<String>();

  int? addTiget(ITidget tiget) {
    _tigets.add(tiget);
    if (_tigets.length == 1) {
      _tigets.first.focuse = true;
    }
    if (tiget is Interactive) {
      final index = _tigets.length;
      _interactive.add(tiget as Interactive);
      return index;
    }

    return null;
  }

  Future<void> listen() async {
    final commandBuffer = <String>[];

    while (_run) {
      final event = await _lib.readEvent(timeout: 50);
      if (event is! KeyEvent) {
        continue;
      }

      _isEndCommand(event);

      if (_switchTigetHandler(event, commandBuffer)) {
        continue;
      }

      final (_, inFocuse) = _getFocuse();
      if (inFocuse is Interactive) {
        (inFocuse as Interactive).setKeyEvent(event);
      }
    }
  }

  void toDebugBuffer(String mes) {
    _debugConsole.addFirst(mes);
    if (_debugConsole.length > 5) {
      _debugConsole.removeLast();
    }
  }

  void render() {
    _lib
      ..enableAlternateScreen()
      ..eraseClear()
      ..cursorHide();
    _lib.enableRawMode();

    Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!_run) {
        t.cancel();
      }

      for (var item in _tigets) {
        item.render(_shadowConsole);
      }

      _shadowConsole.writeAt(stdout.terminalLines - 6, 1, "_" * (stdout.terminalColumns - 5).round());
      
      for (var (i, s) in _debugConsole.indexed) {
          _shadowConsole.writeAt(stdout.terminalLines - 5 + i, 3, s);
      }

      _shadowConsole.comparete();

      _lib.startSyncUpdate();
      _shadowConsole.render(_lib);
      _lib.endSyncUpdate();
    });
  }

  void end() {
    _run = false;
    _lib.disableRawMode();
    _lib
      ..disableAlternateScreen()
      ..cursorShow();

    _lib.flushThenExit(0);
  }

  void _focuseNext() {
    final (index, _) = _getFocuse();
    final nextIndex = (index + 1) % _tigets.length;
    _tigets[index].focuse = false;
    _tigets[nextIndex].focuse = true;
  }

  void _focusePrev() {
    final (index, _) = _getFocuse();
    final prevIndex = index == 0 ? _tigets.length - 1 : index - 1;
    _tigets[index].focuse = false;
    _tigets[prevIndex].focuse = true;
  }

  (int, ITidget) _getFocuse() => _tigets.indexed.firstWhere((e) => e.$2.focuse);

  bool _isSwitchTigetCommand(KeyEvent e) {
    return e.modifiers.has(KeyModifiers.ctrl) && e.code.char == 'w';
  }

  bool _switchTigetHandler(KeyEvent e, List<String> buff) {
    if (_isSwitchTigetCommand(e) && buff.isEmpty) {
      buff.add('ctrl+w');
      return true;
    }

    if (buff.isNotEmpty) {
      if (e.code.char == 'w' || e.code.name == KeyCodeName.right) {
        _focuseNext();
      } else if (e.code.name == KeyCodeName.left) {
        _focusePrev();
      }
      buff.clear();

      return true;
    }

    return false;
  }

  void _isEndCommand(KeyEvent e) {
    if (e.modifiers.has(KeyModifiers.ctrl) && e.code.char == 'c') {
      end();
    }
  }
}

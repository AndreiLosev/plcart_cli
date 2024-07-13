import 'dart:async';

import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

class TuiApp {
  final _lib = TermLib();
  final _tigets = <ITidget>[];
  final _interactive = <Interactive>[];
  bool _run = true;

  int? addTiget(ITidget tiget) {
    _tigets.add(tiget);
    if (tiget is Interactive) {
      final index = _tigets.length;
      _interactive.add(tiget as Interactive);
      return index;
    }

    return null;
  }

  void setChanelsToInteractive(int index, Stream rx, StreamSink tx) {
    _interactive[index].setChanels(rx, tx);
  }

  Future<void> listen() async {
    final commandBuffer = <String>[];

    while (_run) {
      final event = await _lib.readEvent(timeout: 50);
      if (event is! KeyEvent) {
        continue;
      }

      if (_switchTigetHandler(event, commandBuffer)) {
        continue;
      }

      final (_, inFocuse) = _getFocuse();
      if (inFocuse is Interactive) {
        (inFocuse as Interactive).setKeyEvent(event);
      }
    }
  }

  void render() {
    _lib
      ..enableAlternateScreen()
      ..eraseClear()
      ..cursorHide();
    _lib.enableRawMode();

    Timer.periodic(const Duration(milliseconds: 30), (t) {
      try {
        if (!_run) {
          t.cancel();

          _lib.startSyncUpdate();
          _lib.eraseClear();

          for (var item in _tigets) {
            item.render(_lib);
          }

          _lib.endSyncUpdate();
        }
      } finally {
        _lib
          ..disableAlternateScreen()
          ..cursorShow();

        _lib.flushThenExit(0);
      }
    });
  }

  void end() {
    _run = false;
    _lib.disableRawMode();
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
    if (_isSwitchTigetCommand(e)) {
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
}

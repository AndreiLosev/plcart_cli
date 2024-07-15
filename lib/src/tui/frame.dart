import 'package:plcart_cli/src/tui/itidget.dart';
import 'package:plcart_cli/src/tui/shadow_console.dart';
import 'package:termlib/termlib.dart';

class Frame implements ITidget {
  static const _board = ['─', '│', '┌', '┐', '└', '┘'];
  static final _boardColor = _board.map((i) => Style(i)..fg(Color.brightGreen)).toList();

  int width;
  int height;
  int letf;
  int top;

  @override
  bool focuse = false;

  Frame(this.width, this.height, this.letf, this.top);

  int contentLeft([int add = 0]) => letf + 2 + add;
  int contentWidth([int add = 0]) => width - 3 + add;
  int contentTop([int add = 0]) => top + 1 + add;
  int contentHeight([int add = 0]) => height - 2 + add;

  @override
  void render(ShadowConsole lib) {
    List<Object> board = _getBoard(lib);

    for (var i = 0; i < width; i++) {
      lib.writeAt(top, letf + 1 + i, board[0]);
      lib.writeAt(top + height, letf + 1 + i, board[0]);
    }

    for (var i = 0; i < height - 1; i++) {
      lib.writeAt(top + 1 + i, letf, board[1]);
      lib.writeAt(top + 1 + i, letf + width, board[1]);
    }

    lib.writeAt(top, letf, board[2]);
    lib.writeAt(top, letf + width, board[3]);
    lib.writeAt(top + height, letf + width, board[5]);
    lib.writeAt(top + height, letf, board[4]);
  }

  List<Object> _getBoard(ShadowConsole lib) => switch (focuse) {
        true => _boardColor,
        false => _board,
      };
}

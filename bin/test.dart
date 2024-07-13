import 'package:termlib/termlib.dart';
import 'package:termparser/termparser_events.dart';

void main(List<String> args) async {
  final t = TermLib();

  await t.withRawModeAsync(() async {
    while (true) {
      final e = await t.readEvent();

      if (e is! KeyEvent) {
        continue;
      }

      if (e.code.name == KeyCodeName.escape) {
        break;
      }

      print([e.modifiers.has(KeyModifiers.ctrl), e.code.char]);
    }
  });
}

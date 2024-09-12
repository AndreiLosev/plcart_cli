import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';

void main(List<String> args) {
  final searcher = StyleSearcher();

  final s =
      "${Style('|')..fg(Color.green)} #T_1m ${Style('|')..fg(Color.green)}";

  print(searcher.search(s));
}

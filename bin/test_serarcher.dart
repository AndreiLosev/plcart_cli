import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';

void main(List<String> args) {
  final searcher = StyleSearcher();

  final s1 = 'hello. ';
  final s2 = Style('world')..fg(Color.yellow)..bold();
  final s3 = '!!!';

  print(searcher.search('$s1$s2$s3').map((e) => e.toStyledChars()).expand((x) => x).toList());
}

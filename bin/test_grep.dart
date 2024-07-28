import 'package:plcart_cli/src/tui/colorist.dart';
import 'package:plcart_cli/src/tui/grep.dart';
import 'package:plcart_cli/src/tui/methods_finder.dart';
import 'package:termlib/termlib.dart';

void main(List<String> args) async {
  final grep = Grep("/home/andrei/documents/my/plcartProject/test1");
  final c = Colorist();
  final x = await grep.search('MyTaskImp');

  // print(x);
  final x1 = c.paintMethods('qwe', x);
  print(x1);

  // final y1 = x.replaceAllMapped(RegExp("incrimet\\(.*\\)( |;)"), (m) {
  //   final s = Style('incrimet')..fg(Color.blue);
  //   return m[0]!.replaceFirst('incrimet', s.toString());
  // });
  // print(y1);
}

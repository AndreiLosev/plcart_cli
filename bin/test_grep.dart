import 'package:plcart_cli/src/tui/colorist.dart';
import 'package:plcart_cli/src/tui/fields_finder.dart';
import 'package:plcart_cli/src/tui/grep.dart';

void main(List<String> args) async {
  final f = {
    'bb1': false,
    'xx2': 15,
    'yy3': 13.48,
    'ss4': "hello world",
    'll5': [1, 2, true, 'dasa'],
    'mm6': {'q': 1, 'w': 2},
  };
  final grep = Grep("/home/andrei/documents/my/plcartProject/test1");
  final c = Colorist();
  final x = await grep.search('MyTaskImp');
  final y = c.paintSrc('MyTaskImp', x, f);

  print(y);
}

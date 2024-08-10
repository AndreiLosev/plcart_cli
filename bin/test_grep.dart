import 'package:plcart_cli/src/tui/colorist.dart';
import 'package:plcart_cli/src/tui/grep.dart';

void main(List<String> args) async {
  final f = {
    'bb1': false,
    'xx2': 15,
    'yy3': 13.48,
    'ss4': "hello world",
    'll5': [false, 45, 0.1, 'dasa'],
    'mm6': {'key11': 33},
    'timer': [
      "TOn",
      {'in1': true}
    ],
  };
  final grep = Grep("/home/andrei/documents/my/plcartProject/test1");
  final c = Colorist();
  final x = await grep.search('MyTaskImp');
  final y = c.paintSrc('MyTaskImp', x, f);

  print(y);
}

import 'package:plcart_cli/src/tui/main_tiget_fields/colorist.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/grep.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/methods_finder.dart';

void main(List<String> args) async {
  f2();
}

void f1() async {
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

void f2() async {
  final f = {
    'timerTon': [
      'Ton',
      {
        'in1': true,
        'pt': "#T 5s 450ms",
        'q': false,
        'et': "#T 2s 350ms",
      }
    ],
    'timerTof': [
      "TOf",
      {
        'in1': true,
        'pt': "#T 5s 450ms",
        'q': false,
        'et': "#T 2s 350ms",
      }
    ],
    'timerPT': [
      "TP",
      {
        'in1': true,
        'pt': "#T 5s 450ms",
        'q': false,
        'et': "#T 2s 350ms",
      }
    ],
  };
  final grep = Grep("/home/andrei/documents/my/plcartProject/test1");
  // final m = MethodsFinder();
  final c = Colorist();
  final x = await grep.search('OneMoreTask');
  final y = c.paintSrc('OneMoreTask', x, f);
  print(y);
}

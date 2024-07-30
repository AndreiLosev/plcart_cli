import 'package:plcart_cli/src/tui/colorist.dart';

void main(List<String> args) {
  final c = Colorist();
  final data = [
    'TestTask',
    {
      'b': true,
      'x': 15,
      'y': 96.69,
      's': "hello wasa",
      'l': [1, 2, true, 'ok'],
      'm': {'1': 2},
      'timer': [
        "Ton",
        {
          'in1': false,
          'pt': "#T 15s 45ms",
          'q': false,
          'et': "#T 0s",
        }
      ],
    }
  ];
}

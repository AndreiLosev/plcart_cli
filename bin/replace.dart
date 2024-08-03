import 'dart:io';

import 'package:plcart_cli/src/tui/colorist.dart';
import 'package:termlib/termlib.dart';

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
  
  final buffer = StringBuffer();
  for (final MapEntry(key: taskName, value: fields) in {'TestTask': data}.entries) {
        final s = Style("$taskName:")
          ..bold()
          ..fg(Color('81'))
          ..underline();
        buffer.writeln("  $s");
        if (c.isSubtipe(fields)) {
          buffer.writeln(c.setTaskFieds(fields[1] as Map));
        } else {
          buffer.writeln(c.setTaskFieds(fields as Map));
        }
      }

  for (var e in buffer.toString().split(Platform.lineTerminator)) {
    print(e);
  }
}

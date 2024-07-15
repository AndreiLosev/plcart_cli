import 'package:termlib/termlib.dart';

void main(List<String> args) {
  final lib = TermLib();

  // final shc = ShadowConsole();

  final text1 = Style('|')..bg(Color.blue)..fg(Color.brightYellow)..underline();
  final text2 = Style("<>")..bg(Color.green)..reverse();
  final text3 = Style('<=|=>')..bg(Color.magenta)..fg(Color.brightCyan)..bold()..reverse();
  // final (i, chari) = text.toString().runes.indexed.firstWhere((e) => e.$2 == text.text.runes.first);
  // final (j, charj) = text.toString().runes.indexed.lastWhere((e) => e.$2 == text.text.runes.last);

  // print({i: String.fromCharCode(chari), j: String.fromCharCode(charj)});
  // lib.write(String.fromCharCodes(text.toString().runes.take(i + 1)));
  // lib.write(" ");
  // lib.write(String.fromCharCodes(text.toString().runes.skip(i).take(j - i)));
  // lib.write(" ");
  // lib.write(String.fromCharCodes(text.toString().runes.skip(j)));

  print(asTerminal("hel \n привет мир !!"));
  print([text1, text2, text3]);
  print([
    asTerminal(text1),
    asTerminal(text2),
    asTerminal(text3),
  ]);

  //   shc.writeAt(1, 1, text);

  // shc.comparete();

  // shc.render(lib);

  // sleep(Duration(seconds: 10));
}

Iterable<String> asTerminal(Object s) {
  final text = s.toString();
  switch (s) {
    case Style():
      switch (s.text.length) {
        case 1:
          return [text];
        case 2:
          final p = text.replaceFirst(s.text, '   ');
          final [start, end] = p.split('   ');
          return ["$start${s.text[0]}", "${s.text[1]}$end"];  
        default:
          final p = text.replaceFirst(s.text, '   ');
          final [start, end] = p.split('   ');
          final result = <String>[];
          for (var i = 0; i < s.text.length; i++) {
            if (i == 0) {
              result.add("$start${s.text[i]}");
            } else if (i == s.text.length - 1) {
              result.add("${s.text[i]}$end");
            } else {
              result.add(s.text[i]);
            }
          }
          return result;
      }
    default:
      return text.runes.map((e) => String.fromCharCode(e));
  }
}

import 'package:termlib/termlib.dart';

void main(List<String> args) {
  final x = '123';
  final s1 = Style(x)..bg(Color.red);
  final s2 = Style(x)..bg(Color.red);

  print([s1.toString(), s2]);
}

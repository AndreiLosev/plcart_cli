import 'package:termlib/termlib.dart';

void main(List<String> args) {
  final fn = "final z = 8;\n testfn(5, 5.1);\n var zz = 12;\n testfn();";
  final x = fn.replaceAllMapped(RegExp(" testfn\\(.*\\)( |;)"),  (Match x) {
    return x[0]!.replaceFirst('testfn', (Style('tesstFn')..fg(Color.blue)).toString());
  });

  print(x);
}

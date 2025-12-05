import 'package:path/path.dart' as path;

void main(List<String> args) {
  final x = '/home/andrei/documents/my/plcartProject/test1/';
  print([path.dirname(x), path.basename(x)]);
}

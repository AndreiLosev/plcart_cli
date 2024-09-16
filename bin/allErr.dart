import 'package:plcart_cli/src/command.dart';

void main(List<String> args) async {
  final myArgs = [
    "--work-dir=/home/andrei/documents/my/plcartProject/test1/",
  ];
  final command = Command(myArgs);
  await command.showErrors();
}

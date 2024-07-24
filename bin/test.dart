import 'package:plcart_cli/src/command.dart';

void main(List<String> args) async {
  final command = Command();
  await command.debug("127.0.0.1");
}

import 'dart:async';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:plcart_cli/src/client.dart';

void main(List<String> arguments) async {
  final c = Stopwatch();
  c.start();
  final client = Client("127.0.0.1:11223");
  await client.connect();
  listen(client, c);

  client.write(ClientCommand(CommandKind.getRegisteredTasks, null));
  client.write(ClientCommand(CommandKind.getRegisteredEvents, null));
  client.write(ClientCommand(
      CommandKind.runEvent, RunEventPayload("TestEvent", [1], {'q': "wasa"})));
  client.write(ClientCommand(
      CommandKind.subscribeTask, SimplePayload({'value': "TestTask1"})));
  await Future.delayed(const Duration(seconds: 5));
  client.write(ClientCommand(
      CommandKind.subscribeTask, SimplePayload({'value': "TestTask2"})));
  client.write(ClientCommand(
      CommandKind.unsubscribeTask, SimplePayload({"value": "TestTask1"})));
  await Future.delayed(const Duration(seconds: 5));
  client.write(ClientCommand(
      CommandKind.unsubscribeTask, SimplePayload({'value': "TestTask2"})));
}

Future<void> listen(Client client, Stopwatch t) async {
  while (true) {
    final res = await client.read();
    print({res.responseStatus: res.message, 't': t.elapsed});
  }
}

import 'dart:async';
import 'dart:io';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:plcart_cli/src/client.dart';

void main(List<String> arguments) async {
  final c = Stopwatch();
  c.start();
  final soket = await Socket.connect('127.0.0.1', 11223);
  final client = Client(soket);
  listen(client, c);

  client.write(ClientCommand(CommandKind.getRegisteredTasks, null), 1);
  client.write(ClientCommand(CommandKind.getRegisteredEvents, null), 2);
  client.write(ClientCommand(CommandKind.runEvent,
      RunEventPayload("TestEvent", [10000000000], {'y': 0.00000000009})), 3);
  client.write(ClientCommand(
      CommandKind.subscribeTask, SimplePayload({'value': "TestTask1"})), 4);
  await Future.delayed(const Duration(seconds: 5));
  client.write(ClientCommand(
      CommandKind.subscribeTask, SimplePayload({'value': "TestTask2"})), 5);
  client.write(ClientCommand(
      CommandKind.unsubscribeTask, SimplePayload({"value": "TestTask1"})), 6);
  await Future.delayed(const Duration(seconds: 5));
  client.write(ClientCommand(
      CommandKind.unsubscribeTask, SimplePayload({'value': "TestTask2"})), 7);

  await client.disconnect();
}

Future<void> listen(Client client, Stopwatch t) async {
  while (client.isConnected()) {
    final res = await client.read();
    print({res.responseStatus: res.message, 't': t.elapsed, 'id': res.id});
  }
}

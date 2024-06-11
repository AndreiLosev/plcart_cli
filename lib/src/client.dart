import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:debug_server_utils/debug_server_utils.dart';

class Client {
  final String host;
  late Socket _socket;
  StreamSubscription<Uint8List>? _subscription;

  Client(this.host);

  Future<void> connect() async {
    final hostAndPort = host.split(':').take(2).toList();
    final port = int.parse(hostAndPort[1]);
    _socket = await Socket.connect(hostAndPort[0], port,
        timeout: const Duration(seconds: 5));
  }

  void write(ClientCommand commamd) {
    _socket.add(commamd.toBytes());
  }

  void listen(StreamController<ServerResponse> sController) {
    _subscription = _socket.listen((data) {
      sController.add(ServerResponse.fromBytes(data));
    }, onDone: () => disconnect());
  }

  Future<void> disconnect() async {
    _subscription?.cancel();
    _subscription = null;
    await _socket.close();
    _socket.destroy();
  }
}

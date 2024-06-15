import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:future_soket/future_soket.dart';

class Client {
  final String host;
  late FutureSoket _socket;
  StreamSubscription<Uint8List>? _subscription;

  Client(this.host);

  Future<void> connect() async {
    final hostAndPort = host.split(':').take(2).toList();
    final port = int.parse(hostAndPort[1]);
    final nSocket = await Socket.connect(hostAndPort[0], port,
        timeout: const Duration(seconds: 5));

    _socket = FutureSoket.fromSoket(nSocket);
  }

  void write(ClientCommand commamd) {
    writePacket(_socket, commamd.kind.code(), commamd.payload?.toMap());
  }

  Future<ServerResponse> read() async {
    final (type, payload) = await readPacket(_socket);

    return ServerResponse(type.toResponseStatus(), payload);
  }


  Future<void> disconnect() async {
    _subscription?.cancel();
    _subscription = null;
    await _socket.disconnect();
  }
}

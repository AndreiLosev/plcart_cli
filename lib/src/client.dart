import 'dart:async';
import 'dart:io';

import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:future_soket/future_soket.dart';

class Client {
  late FutureSoket _socket;

  Client(Socket soket) {
    _socket = FutureSoket.fromSoket(soket);
  }

  void write(ClientCommand commamd, [int requestId = 0]) {
    writePacket(_socket, commamd.kind.code(), requestId, commamd.payload?.toMap());
  }

  Future<ServerResponse> read() async {
    final (type, id, payload) = await readPacket(_socket);

    return ServerResponse(type.toResponseStatus(), payload, id);
  }


  Future<void> disconnect() async {
    await _socket.disconnect();
  }

  bool isConnected() => _socket.isConnected();
}

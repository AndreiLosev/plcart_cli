import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:path/path.dart';

void main(List<String> args) async {
  final key = await File('/home/andrei/.ssh/id_rsa').readAsString();
  final client = SSHClient(
    await SSHSocket.connect('cloud.softkip.ru', 22),
    username: 'root',
    identities: SSHKeyPair.fromPem(key),
  );

  final sftp = await client.sftp();

  try {
    await sftp.listdir('/qwe1123');
  } on SftpStatusError catch (e) {
    print('error 1');
    if (e.toString().contains('No such file')) {
      print('фаил не существует');
    }
  }
  client.close();
}

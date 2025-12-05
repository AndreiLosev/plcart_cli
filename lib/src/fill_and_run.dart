import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:debug_server_utils/debug_server_utils.dart';
import 'package:path/path.dart' as p;
import 'package:plcart_cli/src/config_builder.dart';

class FillAndRun {
  final ConfigBuilder _config;
  late final String _buildDir;
  late final _binName = p.basename(_config.workDir);

  FillAndRun(this._config) {
    _buildDir = "${_config.workDir}/build";
  }

  Future<void> build() async {
    if (!await Directory(_buildDir).exists()) {
      await Directory(_buildDir).create();
    }
    final params = [
      'compile',
      'exe',
      '--target-os=${_config.os}',
      if (_config.arch.isNotEmpty) '--target-arch=${_config.arch}',
      _config.entryPoint,
      '-o',
      '$_buildDir/$_binName',
    ];
    final res = await Process.run('dart', params);
    if (res.exitCode > 0) {
      throw res.stderr;
    }
  }

  Future<void> fill([FillType type = FillType.ssh]) async {
    switch (type) {
      case FillType.ssh:
      default:
        throw Exception('unsuported fill type $type');
    }
  }

  Future<void> sshfill() async {
    _config.sshCheckThrow();
    final client = await _makeSSHClient();
    final sftp = await client.sftp();
    await _makeDefaultPath(sftp);
    final bin = await File('$_buildDir/$_binName').readAsBytes();
    final remoteFile = await sftp.open(
      '/opt/plcart/bin/${p.basename(_config.workDir)}',
      mode: SftpFileOpenMode.write,
    );
    await remoteFile.writeBytes(bin);

    //TODO: make systed config
    await client.execute('systemctl restrt plcart_$_binName.service');
    sftp.close();
    client.close();
  }

  Future<void> _makeDefaultPath(SftpClient sftp) async {
    try {
      await sftp.listdir('/opt/plcart/bin');
    } on SftpStatusError catch (e) {
      print('error 1');
      if (e.toString().contains('No such file')) {
        await _makeDirIfNotExists(sftp, '/opt');
        await _makeDirIfNotExists(sftp, '/opt/plcart');
        await _makeDirIfNotExists(sftp, '/opt/plcart/bin');
      }
    }
  }

  Future<void> _makeDirIfNotExists(SftpClient sftp, String path) async {
    final name = p.basename(path);
    final list = await sftp.listdir(p.dirname(path));

    for (var fse in list) {
      if (fse.filename == name) {
        return;
      }
    }

    await sftp.mkdir(path);
  }

  Future<SSHClient> _makeSSHClient() async {
    _config.sshCheckThrow();
    return SSHClient(
      await SSHSocket.connect(_config.host, int.parse(_config.sshPort)),
      username: _config.sshName,
      onPasswordRequest: () => _config.sshPassword,
      identities: _config.sshPassword.isNotEmpty
          ? SSHKeyPair.fromPem(await File(_config.sshKey).readAsString())
          : null,
    );
  }
}

enum FillType { local, ssh, docker }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:dartssh2/dartssh2.dart';
import 'package:plcart_cli/src/config_builder.dart';
import 'package:plcart_cli/src/utils/systmd_service.dart';

class SshClient {
  final ConfigBuilder _config;

  SSHClient? _client;
  SftpClient? _sftp;

  SshClient(this._config);

  Future<void> makePath(String path) async {
    final sftp = await _getSftp();
    try {
      await sftp.listdir(path);
    } on SftpStatusError catch (e) {
      print('error 1');
      if (e.toString().contains('No such file')) {
        var partPath = '';
        for (var part in path.split('/')) {
          partPath = "$partPath/$part";
          await makeDirIfNotExists('/opt');
        }
      }
    }
  }

  Future<void> makeDirIfNotExists(String path) async {
    final sftp = await _getSftp();
    final name = p.basename(path);
    final list = await sftp.listdir(p.dirname(path));

    for (var fse in list) {
      if (fse.filename == name) {
        return;
      }
    }

    await sftp.mkdir(path);
  }

  Future<void> moveFile(String localPath, String remotePath) async {
    final bin = await File(localPath).readAsBytes();
    await writeFile(remotePath, bin);
  }

  Future<void> writeFile(String remotePath, Uint8List content) async {
    final sftp = await _getSftp();
    final remoteFile = await sftp.open(
      remotePath,
      mode: SftpFileOpenMode.write,
    );
    await remoteFile.writeBytes(content);
  }

  Future<SSHClient> _getSsh() async {
    if (_client != null && !_client!.isClosed) {
      return _client!;
    }
    _config.sshCheckThrow();
    _client = SSHClient(
      await SSHSocket.connect(_config.host, int.parse(_config.sshPort)),
      username: _config.sshName,
      onPasswordRequest: () => _config.sshPassword,
      identities: _config.sshPassword.isNotEmpty
          ? SSHKeyPair.fromPem(await File(_config.sshKey).readAsString())
          : null,
    );

    return _client!;
  }

  void closeAll() {
    _sftp?.close();
    _client?.close();
  }

  Future<SftpClient> _getSftp() async {
    if (_sftp != null) {
      return _sftp!;
    }
    final client = await _getSsh();
    _sftp = await client.sftp();
    return _sftp!;
  }

  Future<String> _executeCommand(String command) async {
    final client = await _getSsh();
    final session = await client.execute(command);
    final output = await session.stdout.join();
    await session.done;
    return output;
  }

  /// Checks if a systemd service exists
  Future<bool> checkServiceExists(String serviceName) async {
    try {
      final output = await _executeCommand(
        'systemctl list-unit-files --type=service | grep -E "^$serviceName\\.service"',
      );
      return output.trim().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createServiceFromTemplate(
    String serviceName,
    String execPath, {
    String description = 'Мой сервис',
  }) async {
    var serviceContent = systemdService
        .replaceAll('{{ Description }}', description)
        .replaceAll('{{ ExecStart }}', execPath)
        .replaceAll('{{ SyslogIdentifier }}', serviceName);

    final serviceFilePath = '/etc/systemd/system/$serviceName.service';
    await writeFile(serviceFilePath, utf8.encode(serviceContent));

    await _executeCommand('systemctl daemon-reload');
  }

  /// Ensures service exists, creates it from template if it doesn't
  Future<void> ensureServiceExists(
    String serviceName,
    String execPath, {
    String description = 'Мой сервис',
  }) async {
    final exists = await checkServiceExists(serviceName);
    if (!exists) {
      await createServiceFromTemplate(
        serviceName,
        execPath,
        description: description,
      );
    }
  }

  Future<void> startService(String serviceName) async {
    await _executeCommand('systemctl start $serviceName.service');
  }

  Future<void> stopService(String serviceName) async {
    await _executeCommand('systemctl stop $serviceName.service');
  }

  Future<void> restartService(String serviceName) async {
    await _executeCommand('systemctl restart $serviceName.service');
  }

  Future<String> getServiceStatus(String serviceName) async {
    return await _executeCommand(
      'systemctl status $serviceName.service --no-pager',
    );
  }

  Future<void> enableService(String serviceName) async {
    await _executeCommand('systemctl enable $serviceName.service');
  }

  Future<void> disableService(String serviceName) async {
    await _executeCommand('systemctl disable $serviceName.service');
  }

  Future<bool> isServiceActive(String serviceName) async {
    final output = await _executeCommand(
      'systemctl is-active $serviceName.service',
    );
    return output.trim() == 'active';
  }

  Future<bool> isServiceEnabled(String serviceName) async {
    final output = await _executeCommand(
      'systemctl is-enabled $serviceName.service',
    );
    return output.trim() == 'enabled';
  }
}

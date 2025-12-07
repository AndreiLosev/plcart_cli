import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:plcart_cli/src/config_builder.dart';
import 'package:plcart_cli/src/ssh_client.dart';

class FlashAndRun {
  final ConfigBuilder _config;
  late final SshClient _ssh;
  late final String _buildDir;
  late final _binName = p.basename(_config.workDir);
  final String remobteBinPath = '/opt/plcart/bin';

  FlashAndRun(this._config) {
    _buildDir = "${_config.workDir}/build";
    _ssh = SshClient(_config);
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

  Future<void> flash([FlashType type = FlashType.ssh]) async {
    switch (type) {
      case FlashType.ssh:
        await sshFlash();
      default:
        throw Exception('unsuported slash type $type');
    }
  }

  Future<void> sshFlash() async {
    await build();
    await _ssh.makePath(remobteBinPath);
    await _ssh.ensureServiceExists(
      'plcart-$_binName',
      '$remobteBinPath/$_binName',
    );

    await _ssh.stopService('plcart-$_binName');
    await _ssh.moveFile("$_buildDir/$_binName", '$remobteBinPath/$_binName');
    await _ssh.startService('plcart-$_binName');
    await _ssh.enableService('plcart-$_binName');
  }
}

enum FlashType { local, ssh, docker }

import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

class ConfigBuilder {
  late final String workDir;
  late final String host;
  late final String os;
  late final String arch;
  late final String entryPoint;
  late final String sshPort;
  late final String sshName;
  late final String sshPassword;
  late final String sshKey;

  final _cliParser = ArgParser();

  late Map<String, dynamic> _config;
  late ArgResults _cliArgs;

  ConfigBuilder() {
    _cliParser
      ..addOption('work-dir')
      ..addOption('host')
      ..addOption('target-os')
      ..addOption('target-arch')
      ..addOption('entry-point')
      ..addOption('ssh-name')
      ..addOption('ssh-port')
      ..addOption('ssh-password')
      ..addOption('ssh-key');
  }

  Future<void> build(List<String> args) async {
    _cliArgs = _cliParser.parse(args);
    workDir = _cliArgs.option('work-dir') ?? Directory.current.path;
    _config = await loadConfig();

    host = _getValue('host', '127.0.0.1');
    os = _getValue('target-os', Platform.operatingSystem);
    arch = _getValue('target-arch', '');
    entryPoint = _getEntryPoint(
      _getValue('entry-point', "${p.basename(workDir)}.dart"),
    );
    sshName = _getValue('ssh-name', '');
    sshPort = _getValue('ssh-port', '22');
    sshPassword = _getValue('ssh-password', '');
    sshKey = _getValue('ssh-key', '');
  }

  Future<Map<String, dynamic>> loadConfig() async {
    final fConfig = File(p.join(workDir, 'pubspec.yaml'));
    if (!await fConfig.exists()) {
      return {};
    }

    final config = loadYaml(fConfig.readAsStringSync());

    if (config is! Map) {
      return {};
    }
    final res = config['plcart'];
    if (res is! Map) {
      return {};
    }

    return res.cast();
  }

  String _getValue(String name, String default1) {
    if (_cliArgs.option(name) is String && _cliArgs.option(name)!.isNotEmpty) {
      return _cliArgs.option(name)!;
    }

    if (_config[name] is String && (_config[name] as String).isNotEmpty) {
      return _config[name];
    }

    return default1;
  }

  String _getEntryPoint(String entryPoint) {
    if (p.isAbsolute(entryPoint)) {
      return entryPoint;
    }

    return "$workDir/bin/$entryPoint";
  }

  @override
  String toString() {
    return {
      "workDir": workDir,
      "host": host,
      "os": os,
      "arch": arch,
      "entryPoint": entryPoint,
      "sshPort": sshPort,
      "sshName": sshName,
      "sshPassword": sshPassword,
      "sshKey": sshKey,
    }.toString();
  }

  void sshCheckThrow() {
    final res =
        host.isEmpty ||
        int.tryParse(sshPort) == null ||
        sshName.isEmpty ||
        (sshPassword.isEmpty && sshKey.isEmpty);

    if (res) throw Exception('problems for params $this');
  }
}

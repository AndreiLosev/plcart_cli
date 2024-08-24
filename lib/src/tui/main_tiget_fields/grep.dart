import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:plcart_cli/src/tui/main_tiget_fields/helpers.dart';

class Grep {
  final _cache = <String, String>{};
  final Directory _rootDir;
  late Completer<String> _result;
  late Timer _timeout;

  Grep(String path) : _rootDir = Directory(path);

  Future<String> search(String? taskName) async {
    if (taskName == null) {
      return '';
    }
    _result = Completer();
    _timeout = Timer(const Duration(seconds: 3), _timeoutHandler);
    if (_cache[taskName] != null) {
      return _cache[taskName]!;
    }
    await _echoDir(_rootDir, taskName);

    return await _result.future;
  }

  Future<void> _echoDir(Directory dir, String taskName) async {
    if (_result.isCompleted) {
      return;
    }
    final files = await dir.list().toList();

    for (var f in files) {
      if (_result.isCompleted) {
        return;
      }
      if (p.split(f.path).last.startsWith('.')) {
        continue;
      }
      switch (f.statSync().type) {
        case FileSystemEntityType.file:
          if (!f.path.endsWith('.dart')) {
            continue;
          }
          final res = await match(File(f.path), taskName);
          if (res != null) {
            _cache[taskName] = res;
            _timeout.cancel();
            _result.complete(res);
            return;
          }
        case FileSystemEntityType.directory:
          _echoDir(Directory(f.path), taskName);
        default:
          continue;
      }
    }
  }

  Future<String?> match(File f, String taskName) async {
    String content = await f.readAsString();
    final match =
        RegExp("class +$taskName.+{", multiLine: true).firstMatch(content);
    if (match == null) {
      return null;
    }
    content = content.substring(match.end + 1);

    final end = brackets(content);
    return content.substring(0, end);
  }

  void _timeoutHandler() {
    if (!_result.isCompleted) {
      return;
    }
    _result.complete('');
  }
}

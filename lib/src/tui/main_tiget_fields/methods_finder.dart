import 'dart:io';

import 'package:plcart_cli/src/tui/main_tiget_fields/brackets.dart';

class MethodsFinderResult {
  final String name;
  final String body;
  final String bodyHeader;

  MethodsFinderResult(this.name, this.body, this.bodyHeader);

  @override
  String toString() {
    return {'name': name, 'displayBody': displayBody}.toString();
  }

  String get displayBody => "$bodyHeader${Platform.lineTerminator}$body}";
}

class MethodsFinder with Bracket {
  final _methods = <MethodsFinderResult>[];

  void findMethods(String buff, [String? name]) {
    name ??= 'execute';
    final match = RegExp("$name\\(.*\\).*{").firstMatch(buff);
    if (match == null) {
      return;
    }

    final bodyHeader =
        RegExp(" +[A-Z,a-z,0-9,_]+ $name\\(.*\\).*{").firstMatch(buff)![0] ??
            "  $name() {";

    String body = buff.substring(match.end + 1);
    final end = brackets(body);
    body = body.substring(0, end);

    _methods.add(MethodsFinderResult(name, body, bodyHeader));
    final methods = <String>[];
    for (var match
        in RegExp('( |\${)[A-Z,a-z,0-9,_]+\\(.*\\)( |;)').allMatches(body)) {
      final methodStr = body.substring(match.start, match.end);
      final end = methodStr.indexOf('(');
      final name = methodStr.substring(0, end);
      final m = RegExp('[A-Z,a-z,0-9,_]+').firstMatch(name);
      if (m == null) {
        return;
      }

      methods.add(name.substring(m.start, m.end));
    }

    for (var name in methods) {
      findMethods(buff, name);
    }
  }

  List<MethodsFinderResult> get methods => _methods;

  void clear() => _methods.clear();
}

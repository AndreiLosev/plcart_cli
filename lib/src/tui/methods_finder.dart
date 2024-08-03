import 'package:plcart_cli/src/tui/brackets.dart';

class MethodsFinderResult {
  final String name;

  MethodsFinderResult(this.name);

  @override
  String toString() {
    return {'name': name}.toString();
  }
}

class MethodsFinder with Bracket {
  final _methods = <MethodsFinderResult>[];

  void findMethods(String buff, [String? name]) {
    name ??= 'execute';
    final match = RegExp("$name\\(.*\\).*{").firstMatch(buff);
    if (match == null) {
      return;
    }

    String body = buff.substring(match.end + 1);
    final end = brackets(body);
    body = body.substring(0, end);

    _methods.add(MethodsFinderResult(name));
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

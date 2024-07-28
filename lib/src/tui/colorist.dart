import 'dart:io';

import 'package:plcart_cli/src/tui/methods_finder.dart';
import 'package:termlib/termlib.dart';

class Colorist {
  static final stdTypes = "(void|bool|int|double|List|Map|Set|Iterable|String)";

  final _methondFinder = MethodsFinder();
  final _cache = <String, String>{};

  Object styledValue(value) {
    return switch (value) {
      bool() => Style(value.toString())..fg(Color.red),
      int() => Style(value.toString())..fg(Color.cyan),
      double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
      String() => Style("'$value'")..fg(Color.green),
      Iterable() => _styledIterable(value),
      Map() => _styledMap(value),
      _ => value,
    };
  }

  String _styledIterable(Iterable it) {
    if (it.length > 10) {
      final str = it
          .take(30)
          .map(styledValue)
          .toList()
          .toString()
          .replaceFirst(']', '');
      List<String> strArr = str.split(',');
      strArr = [
        ...strArr.take(10),
        "${Platform.lineTerminator}      ",
        ...strArr.skip(10).take(10),
        "${Platform.lineTerminator}      ",
        ...strArr.skip(20).take(10),
      ];

      return "${strArr.join(',').trim()}${it.length > 30 ? ', ... ]' : ' ]'}";
    }

    return it.map(styledValue).toList().toString();
  }

  String _styledMap(Map m) {
    final im = m.entries;
    if (im.length > 7) {
      final rm = Map.fromEntries(im
          .take(18)
          .map((e) => MapEntry(styledValue(e.key), styledValue(e.value))));

      final srm = rm.toString().replaceFirst("}", '');
      List<String> srArr = srm.split(',');
      srArr = [
        ...srArr.take(6),
        "${Platform.lineTerminator}      ",
        ...srArr.skip(6).take(6),
        "${Platform.lineTerminator}      ",
        ...srArr.skip(12).take(6),
        m.length > 18 ? ' ... }' : '}',
      ];

      return "${srArr.join(',').trim()}${m.length > 18 ? ', ... }' : ' }'}";
    }

    return Map.fromEntries(
            im.map((e) => MapEntry(styledValue(e.key), styledValue(e.value))))
        .toString();
  }

  String paintMethods(String key, String buff, [String? name]) {
    if (_cache[key] != null) {
      return _cache[key]!;
    }
    _methondFinder.clear();
    _methondFinder.findMethods(buff);

    for (var method in _methondFinder.methods) {
      buff = buff.replaceAllMapped(RegExp(" ${method.name}\\(.*\\)( |;)"), (m) {
        final s = Style(method.name)..fg(Color.blue);
        return m[0]!.replaceFirst(method.name, s.toString());
      });
    }

    buff = buff.replaceAllMapped(
        RegExp("( |\\()$stdTypes( |)"), (m) {
        final x = RegExp(stdTypes).firstMatch(m[0]!)![0]!;
        return m[0]!.replaceFirst(x, "${Style(x)..fg(Color.green)}");
      });

    _cache[key] = buff;
    return buff;
  }
}

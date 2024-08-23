import 'dart:io';

import 'package:plcart_cli/src/tui/main_tiget_fields/fields_finder.dart';
import 'package:plcart_cli/src/tui/main_tiget_fields/methods_finder.dart';
import 'package:termlib/termlib.dart';

class Colorist {
  static final stdTypes = "(void|bool|int|double|List|Map|Set|Iterable|String)";

  final _methondFinder = MethodsFinder();
  final _cache = <String, FieldsFinder>{};

  Object _styledValue(value) {
    return switch (value) {
      bool() => Style(value.toString())..fg(Color.red),
      int() => Style(value.toString())..fg(Color.cyan),
      double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
      String() => _styledString(value),
      Iterable() => _styledIterable(value),
      Map() => _styledMap(value),
      _ => value,
    };
  }

  Object _styledValueShortCollection(value, collectionKey) {
    return switch (value) {
      bool() => Style(value.toString())..fg(Color.red),
      int() => Style(value.toString())..fg(Color.cyan),
      double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
      String() => _styledString(value),
      Iterable() => _styledIterableShort(value, collectionKey),
      Map() => _styledValueShortMap(value, collectionKey),
      _ => value,
    };
  }

  Style _styledString(String value) {
    if (value.startsWith("#T")) {
      return Style(value)
        ..fg(Color.cyan)
        ..underline();
    }

    return Style("'$value'")..fg(Color.green);
  }

  String _styledIterable(Iterable it) {
    if (isSubtipe(it)) {
      final type = Style("${(it as List)[0]}")
        ..fg(Color('79'))
        ..underline();
      final fields = setTaskFieds(it[1], 2);
      return "$type: ${Platform.lineTerminator}$fields";
    }
    if (it.length > 10) {
      final str = it
          .take(30)
          .map(_styledValue)
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

    return it.map(_styledValue).toList().toString();
  }

  String _styledIterableShort(Iterable it, int? index) {
    if (isSubtipe(it)) {
      final type = Style("${(it as List)[0]}")
        ..fg(Color('79'))
        ..underline();
      return type.toString();
    }

    if (index != null) {
      return _styledValue((it as List)[index]).toString();
    }

    return (Style("[ ... ]")..fg(Color.magenta)).toString();
  }

  String _styledValueShortMap(Map m, Object? collectionKey) {
    if (collectionKey != null) {
      return _styledValue(m[collectionKey]).toString();
    }

    return (Style("{ ... }")..fg(Color.magenta)).toString();
  }

  String setTaskFieds(Map fields, [int addSpace = 0]) {
    final buf = StringBuffer();
    for (final MapEntry(key: name, value: value) in fields.entries) {
      final sn = Style("$name")..fg(Color.brightYellow);
      final sv = _styledValue(value);
      buf.writeln("${' ' * addSpace}    $sn: $sv");
    }

    return buf.toString();
  }

  String _styledMap(Map m) {
    final im = m.entries;
    if (im.length > 7) {
      final rm = Map.fromEntries(im
          .take(18)
          .map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value))));

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
            im.map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value))))
        .toString();
  }

  String paintSrc(String key, String buff, Map<String, dynamic> fields) {
    if (_cache[key] != null) {
      return _cache[key]!.insertFields(fields, _styledValueShortCollection);
    }
    _methondFinder.clear();
    _methondFinder.findMethods(buff);

    buff = _methondFinder.methods
        .map((m) => m.displayBody)
        .join("${Platform.lineTerminator}${Platform.lineTerminator}");

    for (var method in _methondFinder.methods) {
      buff = buff.replaceAllMapped(RegExp(" ${method.name}\\(.*\\)( |;)"), (m) {
        final s = Style(method.name)..fg(Color.blue);
        return m[0]!.replaceFirst(method.name, s.toString());
      });
    }

    buff = buff.replaceAllMapped(RegExp("( |\\()$stdTypes( |)"), (m) {
      final x = RegExp(stdTypes).firstMatch(m[0]!)![0]!;
      return m[0]!.replaceFirst(x, "${Style(x)..fg(Color.green)}");
    });

    _cache[key] = FieldsFinder(buff, fields.keys);
    _cache[key]!.seatch();
    _cache[key]!.prepare();
    return _cache[key]!.insertFields(fields, _styledValueShortCollection);
  }

  bool isSubtipe(Object fields) {
    return fields is List &&
        fields.length == 2 &&
        fields[0] is String &&
        fields[1] is Map;
  }
}

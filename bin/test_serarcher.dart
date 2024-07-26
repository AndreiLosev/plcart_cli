import 'package:plcart_cli/src/tui/style_searcher.dart';
import 'package:termlib/termlib.dart';

final sb = StringBuffer();

void main(List<String> args) {
  final searcher = StyleSearcher();

  final x = {
    'maniTask': {
      'b': false,
      'x': 15,
      'y': 13.48,
      's': "hello world",
      'l': [1, 2, true, 'dasa'],
      'm': {'q': 1, 'w': 2},
    }
  };

  for (final MapEntry(key: taskName, value: fields) in x.entries) {
    final s = Style("$taskName:")
      ..bold()
      ..fg(Color('81'))
      ..underline();
    sb.writeln("  $s");
    _setTaskFieds(fields);
  }

  print(searcher
    .search(sb.toString())
    .map((e) => e.toStyledChars())
    .expand((x) => x)
    .toList());
}

void _setTaskFieds(Map fields) {
  for (final MapEntry(key: name, value: value) in fields.entries) {
    final sn = Style("$name")..fg(Color.brightYellow);
    final sv = _styledValue(value);
    sb.writeln("    $sn: $sv");
  }
}

Object _styledValue(value) {
  return switch (value) {
    bool() => Style(value.toString())..fg(Color.red),
    int() => Style(value.toString())..fg(Color.cyan),
    double() => Style(value.toStringAsFixed(4))..fg(Color.magenta),
    String() => Style("'$value'")..fg(Color.green),
    Iterable() => _styledIterable(value),
    Map() => Map.fromEntries(value.entries
        .map((e) => MapEntry(_styledValue(e.key), _styledValue(e.value)))),
    _ => value,
  };
}

Iterable _styledIterable(Iterable it) {
  if (it.length > 10) {
    return it.take(10).map(_styledValue).toList()..add('...');
  }

  return it.map(_styledValue).toList();
}

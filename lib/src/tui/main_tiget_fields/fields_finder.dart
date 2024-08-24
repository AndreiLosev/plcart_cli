import 'package:plcart_cli/src/tui/main_tiget_fields/helpers.dart';
import 'package:termlib/termlib.dart';

final class FieldsFinderResult {
  final int start;
  final String key;
  final Object? collectionkey;

  FieldsFinderResult(this.start, this.key, [this.collectionkey]);

  static int comparate(FieldsFinderResult a, FieldsFinderResult b) =>
      a.start - b.start;
}

class FieldsFinder {
  final String _methodBody;
  final Map<String, dynamic> _fields;
  final _fieldsPositions = <FieldsFinderResult>[];
  final _listPieces = <String>[];

  FieldsFinder(this._methodBody, this._fields);

  Iterable<String> get _keys => _fields.keys;

  void seatch() {
    for (var key in _keys) {
      for (var match1 in RegExp('( |\${|\\(|!|)$key(\\.| |\\)|\\(|;|!|\\?|\\[)')
          .allMatches(_methodBody)) {
        final match = RegExp(key).firstMatch(match1[0]!);
        if (match == null) {
          continue;
        }
        final collectionkey = switch (isSubtipe(_fields[key])) {
          true => _subtipeCollKey(key, match1, _fields[key][1]),
          false => _simepleColKey(match1),
        };

        final res = FieldsFinderResult(
          match1.start + match.start,
          key,
          collectionkey,
        );
        _fieldsPositions.add(res);
      }
    }
  }

  String? _simepleColKey(RegExpMatch match) {
    final keyPostions = _findCollectionKey(match.start);
    return keyPostions != null
        ? _methodBody.substring(keyPostions.$1 + 1, keyPostions.$2)
        : null;
  }

  String? _subtipeCollKey(String key, RegExpMatch match, Map value) {
    final maxKeyLength = value.keys
        .cast<String>()
        .map((e) => e.length)
        .reduce((v, e) => v > e ? v : e);
    final buff =
        _methodBody.substring(match.start, match.end + maxKeyLength + 1);

    for (var subKey in value.keys) {
      if (buff.contains("$key.$subKey")) {
        return subKey;
      }
    }

    return null;
  }

  void prepare() {
    _fieldsPositions.sort(FieldsFinderResult.comparate);
    int gStart = 0;
    for (var ffr in _fieldsPositions) {
      _listPieces.add(
        _methodBody.substring(gStart, ffr.start),
      );
      _listPieces.add(_endcodeKey(ffr.key, ffr.collectionkey));
      gStart = ffr.start + ffr.key.length;
    }

    _listPieces.add(_methodBody.substring(gStart));
  }

  String insertFields(
    Map<String, dynamic> fields,
    Object Function(dynamic, dynamic) setColor,
  ) {
    final buff = StringBuffer();
    for (var piece in _listPieces) {
      if (_hasKey(piece)) {
        final p = Style('|')
          ..fg(Color('244'))
          ..bold();
        final (key, colKey) = _decodeKey(piece);
        final skey = Style(key)..fg(Color.brightYellow);
        buff.write(
          " $p${setColor(fields[key], _parseColkey(colKey))}$p $skey",
        );
      } else {
        buff.write(piece);
      }
    }

    return buff.toString();
  }

  (int, int)? _findCollectionKey(int start) {
    int? open;
    // [].last
    for (var i = start; i < _methodBody.length; i++) {
      switch (_methodBody[i]) {
        case ";" || "\n" || '+' || '-' || '=' || '*' || '/':
          return null;
        case "[" || "f" || "l":
          open = i;
        case "]":
          if (open == null) {
            return null;
          }
          return (open, i);
        case "t":
          if (open == null) {
            return null;
          }
          switch (_methodBody.substring(open, i)) {
            case "firs" || "las":
              return (open - 1, i + 1);
            default:
              return null;
          }
      }
    }

    return null;
  }

  static String _endcodeKey(String key, Object? colKey) =>
      "_#__${key}_|_${colKey}__#_";
  static bool _hasKey(String piece) =>
      piece.startsWith('_#__') && piece.endsWith('__#_');

  static (String, String) _decodeKey(String dkey) {
    final keyAndColKey = dkey.replaceFirst('_#__', '').replaceFirst('__#_', '');
    final [key, colKey] = keyAndColKey.split("_|_");
    return (key, colKey);
  }

  static Object? _parseColkey(String colKey) {
    if (colKey == 'null') {
      return null;
    }
    try {
      return int.parse(colKey);
    } on FormatException {
      return colKey.replaceAll('"', '').replaceAll("'", '');
    }
  }
}

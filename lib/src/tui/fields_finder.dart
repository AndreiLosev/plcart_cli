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
  final Iterable<String> _keys;
  final _fieldsPositions = <FieldsFinderResult>[];
  final _listPieces = <String>[];

  FieldsFinder(this._methodBody, this._keys);

  void seatch() {
    for (var key in _keys) {
      for (var match1 in RegExp('( |\${|\\(|!|)$key(\\.| |\\)|\\(|;|!|\\?|\\[)')
          .allMatches(_methodBody)) {
        final match = RegExp(key).firstMatch(match1[0]!);
        if (match == null) {
          continue;
        }
        final keyPostions = _findCollectionKey(match1.start);
        final collectionkey = keyPostions != null
            ? _methodBody.substring(keyPostions.$1 + 1, keyPostions.$2)
            : null;

        final res = FieldsFinderResult(
          match1.start + match.start,
          key,
          collectionkey,
        );
        _fieldsPositions.add(res);
      }
    }
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
    late int open;
    for (var i = start; i < _methodBody.length; i++) {
      switch (_methodBody[i]) {
        case ";" || "\n":
          return null;
        case "[":
          open = i;
        case "]":
          return (open, i);
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

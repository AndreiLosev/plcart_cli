import 'package:termlib/termlib.dart';

final class FieldsFinderResult {
  final int start;
  final String key;

  FieldsFinderResult(this.start, this.key);

  static int comparate(FieldsFinderResult a, FieldsFinderResult b) =>
      a.start - b.start;

  @override
  String toString() {
    return ("$runtimeType:", {'start': start, 'key': key}).toString();
  }
}

class FieldsFinder{
  final String _methodBody;
  final Iterable<String> _keys;
  final _fieldsPositions = <FieldsFinderResult>[];
  final _listPieces = <String>[];

  FieldsFinder(this._methodBody, this._keys);

  void seatch() {
    for (var key in _keys) {
      for (var match1 in RegExp('( |\${|\\(|!|)$key(\\.| |\\)|;)')
          .allMatches(_methodBody)) {
        final match = RegExp(key).firstMatch(match1[0]!);
        if (match == null) {
          continue;
        }
        final res = FieldsFinderResult(
          match1.start + match.start,
          key,
        );
        _fieldsPositions.add(res);
      }
    }
  }

  void prepare() {
    _fieldsPositions.sort(FieldsFinderResult.comparate);
    int gStart = 0;
    for (var ffr in _fieldsPositions) {
      _listPieces.add(_methodBody.substring(gStart, ffr.start));
      _listPieces.add(_endcodeKey(ffr.key));
      gStart = ffr.start;
    }

    _listPieces.add(_methodBody.substring(gStart));
  }

  String insertFields(Map<String, dynamic> fields) {
    final buff = StringBuffer();
    for (var piece in _listPieces) {
      if (_hasKey(piece)) {
        final p = Style('|')..fg(Color('244'))..bold();
        buff.write(" $p${fields[_decodeKey(piece)]}$p ");
      } else {
        buff.write(piece);
      }
    }

    return buff.toString();
  }

  static String _endcodeKey(String key) => "_#__${key}__#_";
  static bool _hasKey(String piece) =>
      piece.startsWith('_#__') && piece.endsWith('__#_');

  static String _decodeKey(String dkey) =>
      dkey.replaceFirst('_#__', '').replaceFirst('__#_', '');
}

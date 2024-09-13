import 'package:termansi/termansi.dart' as ansi;

final _regexp = RegExp("[0-9]{1,2}m");
final _endStyle = "${ansi.CSI}0m";

class StyleResult {
  final String? style;
  final String text;

  StyleResult(this.text, [this.style]);

  @override
  String toString() {
    if (style == null) {
      return text;
    }

    return "$style$text${ansi.CSI}0m";
  }

  String wrap(String s) {
    if (style == null) return s;
    return "$style$s${ansi.CSI}0m";
  }

  List<String> toStyledChars() {
    return [for (var i = 0; i < text.length; i++) wrap(text[i])];
  }
}

class StyleSearcher {
  List<StyleResult> search(String str) {
    final stylesList = str.split(_endStyle);

    final stylesStart = stylesList
        .map((e) => e.indexOf(ansi.CSI))
        .map((e) => e == -1 ? null : e)
        .toList();

    final stylesEnd = stylesList.indexed.map((e) {
      if (stylesStart[e.$1] == null) {
        return null;
      }
      final start = stylesStart[e.$1]!;
      final result = _regexp.firstMatch(e.$2.substring(start));
      if (result == null) {
        return null;
      }
      return result.end + start;
    }).toList();

    final result = <StyleResult>[];

    for (var (i, s) in stylesList.indexed) {
      if (stylesStart[i] == null ||
          stylesEnd[i] == null ||
          stylesStart[i]! > stylesEnd[i]!) {
        result.add(StyleResult(s));
        continue;
      }

      final before = s.substring(0, stylesStart[i]);
      if (before != '') {
        result.add(StyleResult(before));
      }

      final style = s.substring(stylesStart[i]!, stylesEnd[i]);

      final text = s.substring(stylesEnd[i]!);

      result.add(StyleResult(text, style));
    }

    return result;
  }
}

import 'dart:io';

import 'package:termansi/termansi.dart' as ansi;

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
    return "$style$s${ansi.CSI}0m";
  }
}

class StyleSearcher {
  List<StyleResult> search(String str) {
    final regexp = RegExp("[0-9]{1,2}m");
    final stylesList = str.split("${ansi.CSI}0m");

    final stylesStart = stylesList
        .map((e) => e.indexOf(ansi.CSI))
        .map((e) => e == -1 ? null : e)
        .toList();

    final stylesEnd = stylesList.indexed.map((e) {
      if (stylesStart[e.$1] == -1) {
        return null;
      }

      return regexp.firstMatch(e.$2)?.end;
    }).toList();

    final result = <StyleResult>[];

    for (var (i, s) in stylesList.indexed) {
      if (stylesStart[i] == null || stylesEnd[i] == null) {
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

  List<List<String>> toCharList(String text) {
    final result = <List<String>>[];
    for (var line in text.split(Platform.lineTerminator)) {
      result.add([]);
      for (var i = 0; i < line.length; i++) {
        result.last.add(line[i]);
      }
    }

    return result;
  }
}

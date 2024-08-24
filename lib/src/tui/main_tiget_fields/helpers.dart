int brackets(String content, [int bracketsCount = 1]) {
  for (var i = 0; i < content.length; i++) {
    if (content[i] == "{") {
      bracketsCount++;
    } else if (content[i] == "}") {
      bracketsCount--;
    }
    if (bracketsCount == 0) {
      return i;
    }
  }

  return 0;
}

bool isSubtipe(Object fields) {
  return fields is List &&
      fields.length == 2 &&
      fields[0] is String &&
      fields[1] is Map;
}

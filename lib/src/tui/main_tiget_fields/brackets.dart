mixin Bracket {
  
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
}

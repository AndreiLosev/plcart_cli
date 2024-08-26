void main(List<String> args) {
  var x = [10, 02];
  try {
    print(x[0]);
  } on RangeError {
    print(x.last);
  }
}

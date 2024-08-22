import 'dart:io';

class _Logger {
  static _Logger? _instanse;

  final _file = File("${Directory.current.path}/debug.log");
  final _buffer = StringBuffer();

  _Logger.instanse() {
    _file.writeAsStringSync("");
  }

  factory _Logger() {
    _instanse ??= _Logger.instanse();

    return _instanse!;
  }

  void log(Object o) {
    _buffer.write("###  ");
    _buffer.write(DateTime.now().toLocal());
    _buffer.writeln("  ###");
    _buffer.writeln(o.toString());
    _buffer.writeln("________________________________________________________");
    _buffer.writeln();

    _file.writeAsStringSync(_buffer.toString(), mode: FileMode.append);

    _buffer.clear();
  }
}

void flog(Object o) {
  _Logger().log(o);
}

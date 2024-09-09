import 'package:plcart_cli/src/logger.dart';
import 'package:plcart_cli/src/tui/itidget.dart';

class Errorhandler implements IErrorHandler {
  @override
  void addError(Object err) {
    flog({'error': err});
  }
}

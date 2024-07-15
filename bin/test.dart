import 'dart:async';

import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/tui_app.dart';

void main(List<String> args) async {
  final sc1 = StreamController<Message>();
  final sc2 = StreamController<String>();
  final eventList = DataColumn(
      name: 'test1', width: 16, height: 10, letf: 10, top: 5, widthINdex: true);
  eventList.setChanels(sc1.stream, sc2.sink);
  sc1.add(Message.data('wasa'));
  sc1.add(Message.data('Igor'));
  sc1.add(Message.data('Izmoil'));
  sc1.add(Message.data('balerina'));
  sc1.add(Message.data('wasa'));
  sc1.add(Message.data('Igor'));
  sc1.add(Message.data('Izmoil'));
  sc1.add(Message.data('balerina'));
  sc1.add(Message.data('wasa'));
  sc1.add(Message.data(' Igor'));
  sc1.add(Message.data('Izmoil'));
  sc1.add(Message.data('1balerina'));

  final sc11 = StreamController<Message>();
  final sc21 = StreamController<String>();
  final eventList1 =
      DataColumn(name: 'test__2', width: 15, height: 15, letf: 105, top: 5);
  eventList1.setChanels(sc11.stream, sc21.sink);
  sc11.add(Message.data('w_a_sa'));
  sc11.add(Message.data('Ig_o+r'));
  sc11.add(Message.data('I_zm_oi_l'));
  sc11.add(Message.data('b_al_er_ina'));

  final app = TuiApp();
  app.addTiget(eventList);
  app.addTiget(eventList1);
  app.listen();
  app.render();

  sc2.stream.listen((m) {
    app.toDebugBuffer(m);
  });

  sc21.stream.listen((m) {
    app.toDebugBuffer(m);
  });
}

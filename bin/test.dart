import 'dart:async';

import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/frame.dart';
import 'package:plcart_cli/src/tui/layout.dart';
import 'package:plcart_cli/src/tui/tui_app.dart';

void main(List<String> args) async {
  final sc1 = StreamController<Message>();
  final sc2 = StreamController<String>();
  final eventList = DataColumn(
      name: 'test1', width: 16, height: 10, letf: 10, top: 5, widthIndex: true);
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
      DataColumn(name: 'test__2', width: 15, height: 15, letf: 165, top: 5);
  eventList1.setChanels(sc11.stream, sc21.sink);
  sc11.add(Message.data('w_a_sa'));
  sc11.add(Message.data('Ig_o+r'));
  sc11.add(Message.data('I_zm_oi_l'));
  sc11.add(Message.data('b_al_er_ina'));
  sc11.add(Message.data('w_#a_sa'));
  sc11.add(Message.data('Ig_o#+r'));
  sc11.add(Message.data('I_zm#_oi_l'));
  sc11.add(Message.data('b_al#_er_ina'));

  final main = Frame(2, 2, 2, 2);
  final console = Frame(2, 2, 2, 2);

  final app = TuiApp();
  app.addTiget(eventList);
  app.addTiget(eventList1);
  app.addTiget(main);
  app.addTiget(console);
  app.listen();
  app.render();

  await Future.delayed(Duration(milliseconds: 250));
  Layout.applay(eventList1, eventList, main, console);

  sc2.stream.listen((m) {
    app.toDebugBuffer(m);
  });

  sc21.stream.listen((m) {
    app.toDebugBuffer(m);
  });

  // Timer.periodic(Duration(seconds: 1), (_) {
  //   eventList.letf += 10;
  // });
}

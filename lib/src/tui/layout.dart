import 'dart:io';

import 'package:plcart_cli/src/tui/data_column.dart';
import 'package:plcart_cli/src/tui/error_handler.dart';
import 'package:plcart_cli/src/tui/frame.dart';

class Layout {
  static void applay(DataColumn events, DataColumn tasks, Frame main,
      Frame conosle, Errorhandler err) {
    final width = stdout.terminalColumns;
    final hieght = stdout.terminalLines;

    final w = [events.innerDataWidth, tasks.innerDataWidth]
        .reduce((e, a) => e > a ? e : a);
    final h1 = tasks.innerDataHeight;
    final h2 = events.innerDataHeight;
    final taskHieght = (h1 * hieght / (h1 + h2)).round();
    final eventHieght = hieght - taskHieght - 6;

    final rightColumnLeft = width - w - 2;

    tasks.top = 1;
    tasks.left = rightColumnLeft;
    tasks.width = w;
    tasks.height = taskHieght;

    events.top = hieght - eventHieght - 4;
    events.left = rightColumnLeft;
    events.width = w;
    events.height = eventHieght;

    main.top = 1;
    main.left = 1;
    main.width = width - tasks.width - 5;
    main.height = hieght - 4;

    conosle.left = 1;
    conosle.top = main.height + 1;
    conosle.width = width - tasks.width - 5;
    conosle.height = 2;

    err.maxTop = (hieght * 0.07).toInt();
    err.maxLeft = (w * 0.3).toInt();
    err.maxWidth = width - err.maxLeft * 2;

    err.minTop = events.top + events.height + 1;
    err.minLeft = rightColumnLeft;
    err.minWidth = w;
    err.minHeight = 2;
  }
}

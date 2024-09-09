import 'package:debug_server_utils/debug_server_utils.dart';

void main(List<String> args) {
  final fields = ["valieOne", "testSet", "run", 'firstAction', "mainMotor"];
  final t1 = 'testSet = 25';
  print(ForseValue.parse('testTask', t1, fields).toMap());

  final t2 = 'testSet add 25';
  print(ForseValue.parse('testTask', t2, fields).toMap());

  final t3 = 'testSet remove 25';
  print(ForseValue.parse('testTask', t3, fields).toMap());

  final t4 = "testSet[1][2][wasa][ig_or][1_2] = 25";
  final f = ForseValue.parse('testTask', t4, fields);
  print(f.toMap());

  final t5 = "testSet[1][2][wasa][ig_or][1_2] add 25";
  final f1 = ForseValue.parse('testTask', t5, fields);
  print(f1.toMap());
  print(ForseValue.fromMap(f1.toMap()).toMap());
}

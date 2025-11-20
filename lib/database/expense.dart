import 'package:drift/drift.dart';

class Expense extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();
}
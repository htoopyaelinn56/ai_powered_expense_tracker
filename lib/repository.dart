import 'package:ai_powered_expense_tracker/database/database.dart';
import 'package:drift/drift.dart';

class Repository {
  final AppDatabase database;

  Repository(this.database);

  Future<List<ExpenseData>> getAllExpenses() {
    return database.select(database.expense).get();
  }

  Future<int> addExpense(ExpenseCompanion expense) {
    return database.into(database.expense).insert(expense);
  }

  Future<ExpenseData> getExpenseByName(String name) {
    return (database.select(
      database.expense,
    )..where((tbl) => tbl.name.equals(name))).getSingle();
  }

  Future<List<ExpenseData>> getExpenseByDate(DateTime date) {
    return (database.select(
      database.expense,
    )..where((tbl) => tbl.date.equals(date))).get();
  }

  Future<List<ExpenseData>> getExpenseByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (database.select(
      database.expense,
    )..where((tbl) => tbl.date.isBetweenValues(startDate, endDate))).get();
  }
}

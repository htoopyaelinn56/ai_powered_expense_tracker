import 'package:ai_powered_expense_tracker/database/database.dart';
import 'package:drift/drift.dart';

class Repository {
  final AppDatabase _database;

  Repository(AppDatabase database) : _database = database;

  Future<List<ExpenseData>> getAllExpenses() {
    return _database.select(_database.expense).get();
  }

  Future<int> addExpense(ExpenseCompanion expense) {
    return _database.into(_database.expense).insert(expense);
  }

  Future<ExpenseData?> getExpenseByName(String name) {
    return (_database.select(
      _database.expense,
    )..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  Future<List<ExpenseData>> getExpenseByDate(DateTime date) {
    return (_database.select(
      _database.expense,
    )..where((tbl) => tbl.date.equals(date))).get();
  }

  Future<List<ExpenseData>> getExpenseByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (_database.select(
      _database.expense,
    )..where((tbl) => tbl.date.isBetweenValues(startDate, endDate))).get();
  }
}

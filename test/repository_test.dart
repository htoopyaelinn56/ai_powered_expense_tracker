import 'package:ai_powered_expense_tracker/database/database.dart';
import 'package:ai_powered_expense_tracker/repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late Repository repository;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    repository = Repository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Repository.getAllExpenses', () {
    test('returns empty list when there are no expenses', () async {
      final expenses = await repository.getAllExpenses();
      expect(expenses, isEmpty);
    });

    test('returns all inserted expenses', () async {
      final expense1 = ExpenseCompanion.insert(
        name: 'Coffee',
        amount: 3.50,
        date: DateTime(2024, 1, 1),
      );
      final expense2 = ExpenseCompanion.insert(
        name: 'Lunch',
        amount: 12.0,
        date: DateTime(2024, 1, 2),
      );

      await repository.addExpense(expense1);
      await repository.addExpense(expense2);

      final expenses = await repository.getAllExpenses();

      expect(expenses.length, 2);
      expect(expenses.map((e) => e.name), containsAll(['Coffee', 'Lunch']));
    });
  });

  group('Repository.addExpense', () {
    test('inserts an expense and returns its id', () async {
      final expense = ExpenseCompanion.insert(
        name: 'Groceries',
        amount: 45.25,
        date: DateTime(2024, 1, 3),
      );

      final id = await repository.addExpense(expense);

      final expenses = await repository.getAllExpenses();

      expect(expenses.length, 1);
      expect(expenses.first.id, id);
      expect(expenses.first.name, 'Groceries');
      expect(expenses.first.amount, 45.25);
      expect(expenses.first.date, DateTime(2024, 1, 3));
    });

    test('assigns incrementing ids for multiple insertions', () async {
      final expense1 = ExpenseCompanion.insert(
        name: 'Item1',
        amount: 10.0,
        date: DateTime(2024, 1, 4),
      );
      final expense2 = ExpenseCompanion.insert(
        name: 'Item2',
        amount: 20.0,
        date: DateTime(2024, 1, 5),
      );

      final id1 = await repository.addExpense(expense1);
      final id2 = await repository.addExpense(expense2);

      expect(id2, greaterThan(id1));
    });
  });

  group('Repository.getExpenseByName', () {
    test('returns the correct expense for a given name', () async {
      final expense1 = ExpenseCompanion.insert(
        name: 'Taxi',
        amount: 25.0,
        date: DateTime(2024, 1, 6),
      );
      final expense2 = ExpenseCompanion.insert(
        name: 'Dinner',
        amount: 30.0,
        date: DateTime(2024, 1, 7),
      );

      await repository.addExpense(expense1);
      await repository.addExpense(expense2);

      final result = await repository.getExpenseByName('Dinner');

      expect(result?.name, 'Dinner');
      expect(result?.amount, 30.0);
      expect(result?.date, DateTime(2024, 1, 7));
    });

    test('throws when no expense exists for the given name', () async {
      expect(() => repository.getExpenseByName('NonExistent'), returnsNormally);
    });
  });

  group('Repository.getExpenseByDate', () {
    test('returns empty list when no expenses match the date', () async {
      final expense = ExpenseCompanion.insert(
        name: 'Snack',
        amount: 5.0,
        date: DateTime(2024, 1, 8),
      );

      await repository.addExpense(expense);

      final results = await repository.getExpenseByDate(DateTime(2024, 1, 9));

      expect(results, isEmpty);
    });

    test('returns expenses that match the given date', () async {
      final date = DateTime(2024, 1, 10);

      final expense1 = ExpenseCompanion.insert(
        name: 'Breakfast',
        amount: 8.0,
        date: date,
      );
      final expense2 = ExpenseCompanion.insert(
        name: 'Lunch',
        amount: 15.0,
        date: date,
      );
      final otherDateExpense = ExpenseCompanion.insert(
        name: 'Other',
        amount: 20.0,
        date: DateTime(2024, 1, 11),
      );

      await repository.addExpense(expense1);
      await repository.addExpense(expense2);
      await repository.addExpense(otherDateExpense);

      final results = await repository.getExpenseByDate(date);

      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(['Breakfast', 'Lunch']));
    });
  });

  group('Repository.getExpenseByDateRange', () {
    test('returns empty list when no expenses are in the range', () async {
      final expense = ExpenseCompanion.insert(
        name: 'OutOfRange',
        amount: 50.0,
        date: DateTime(2024, 1, 1),
      );

      await repository.addExpense(expense);

      final results = await repository.getExpenseByDateRange(
        DateTime(2024, 2, 1),
        DateTime(2024, 2, 10),
      );

      expect(results, isEmpty);
    });

    test('includes expenses on the start and end dates', () async {
      final expenseBefore = ExpenseCompanion.insert(
        name: 'Before',
        amount: 5.0,
        date: DateTime(2024, 1, 1),
      );
      final expenseStart = ExpenseCompanion.insert(
        name: 'Start',
        amount: 10.0,
        date: DateTime(2024, 1, 10),
      );
      final expenseMiddle = ExpenseCompanion.insert(
        name: 'Middle',
        amount: 15.0,
        date: DateTime(2024, 1, 15),
      );
      final expenseEnd = ExpenseCompanion.insert(
        name: 'End',
        amount: 20.0,
        date: DateTime(2024, 1, 20),
      );
      final expenseAfter = ExpenseCompanion.insert(
        name: 'After',
        amount: 25.0,
        date: DateTime(2024, 1, 25),
      );

      await repository.addExpense(expenseBefore);
      await repository.addExpense(expenseStart);
      await repository.addExpense(expenseMiddle);
      await repository.addExpense(expenseEnd);
      await repository.addExpense(expenseAfter);

      final results = await repository.getExpenseByDateRange(
        DateTime(2024, 1, 10),
        DateTime(2024, 1, 20),
      );

      expect(
        results.map((e) => e.name),
        containsAll(['Start', 'Middle', 'End']),
      );
      expect(results.map((e) => e.name), isNot(contains('Before')));
      expect(results.map((e) => e.name), isNot(contains('After')));
    });
  });
}

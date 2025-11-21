import '../database/database.dart';

sealed class MessageResult {}

final class GetExpensesMessageResult extends MessageResult {
  final List<ExpenseData> expenses;

  GetExpensesMessageResult({required this.expenses});
}

final class AddExpenseMessageResult extends MessageResult {
  final ExpenseCompanion expense;

  AddExpenseMessageResult({required this.expense});
}

final class NoResultMessageResult extends MessageResult {
  final String text;
  final bool isError;

  NoResultMessageResult({required this.text, required this.isError});
}
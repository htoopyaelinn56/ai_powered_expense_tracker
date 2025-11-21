sealed class FunctionCallResult {}

final class NoResultFunctionCall extends FunctionCallResult {
  final String text;
  final bool isError;

  NoResultFunctionCall({required this.text, required this.isError});
}

final class GetExpensesFunctionCall extends FunctionCallResult {
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? name;

  GetExpensesFunctionCall({
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.name,
  });
}

final class AddExpenseFunctionCall extends FunctionCallResult {
  final double amount;
  final String name;
  final DateTime date;

  AddExpenseFunctionCall({
    required this.amount,
    required this.name,
    required this.date,
  });
}

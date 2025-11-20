sealed class FunctionCallResult {}

final class NoResultFunctionCall extends FunctionCallResult {
  final String text;

  NoResultFunctionCall({required this.text});
}

final class GetExpensesFunctionCall extends FunctionCallResult {}

final class AddExpenseFunctionCall extends FunctionCallResult {}

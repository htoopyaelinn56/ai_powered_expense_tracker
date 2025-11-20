import 'dart:convert';
import 'dart:developer';

import 'package:ai_powered_expense_tracker/message_interpretation/function_call_result.dart';
import 'package:ai_powered_expense_tracker/message_interpretation/message_interpret_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MessageInterpreter {
  Future<FunctionCallResult> getFunctionCallResult(String message) async {
    try {
      final payload = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": message},
            ],
          },
        ],
        "tools": [
          {
            "functionDeclarations": [
              {
                "name": "get_expense",
                "description":
                    "Retrieves expenses filtered by date range, specific date, name, or returns all expenses if no filter is provided.",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "date": {
                      "type": "string",
                      "description":
                          "A specific date to retrieve expenses for (e.g., '1. 2. 2025') in dd-mm-yyyy.",
                    },
                    "start_date": {
                      "type": "string",
                      "description":
                          "Start of date range (e.g., '1. 2. 2025') in dd-mm-yyyy.",
                    },
                    "end_date": {
                      "type": "string",
                      "description":
                          "End of date range (e.g., '1. 2. 2025') in dd-mm-yyyy.",
                    },
                    "name": {
                      "type": "string",
                      "description":
                          "The expense name to filter by (e.g., 'Transportation' (don't translate to english)).",
                    },
                  },
                },
              },
              {
                "name": "add_expense",
                "description":
                    "Adds or updates an expense record with amount, name, and date.",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "amount": {
                      "type": "number",
                      "description": "The numerical amount of the expense.",
                    },
                    "name": {
                      "type": "string",
                      "description":
                          "The name of the expense (e.g., 'Groceries', 'Travel' (don't translate to english, just store what user provide)).",
                    },
                    "date": {
                      "type": "string",
                      "description":
                          "The date the expense was incurred (e.g., '1. 2. 2025') in dd-mm-yyyy.",
                    },
                  },
                  "required": ["amount", "name", "date"],
                },
              },
            ],
          },
        ],
      };

      const uri =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
      final headers = {'x-goog-api-key': dotenv.env['GEMINI_API_KEY']!};

      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: jsonEncode(payload),
      );

      final responseBody = jsonDecode(response.body);

      final functionName =
          responseBody['candidates'][0]['content']['parts'][0]['functionCall']['name'];

      final text = responseBody['candidates'][0]['content']['parts'][0]['text'];

      if (functionName == 'get_expense') {
        return GetExpensesFunctionCall();
      } else if (functionName == 'add_expense') {
        return AddExpenseFunctionCall();
      } else {
        return NoResultFunctionCall(text: text);
      }
    } catch (_) {
      rethrow;
    }
  }

  void interpretAndProcess(String message) async {
    try {
      final functionCallResult = await getFunctionCallResult(message);
      switch (functionCallResult) {
        case NoResultFunctionCall():
          // it will show the text response from the AI
          throw UnimplementedError();
        case GetExpensesFunctionCall():
          // will call repository.getAllExpenses() and show the result
          throw UnimplementedError();
        case AddExpenseFunctionCall():
          // will call repository.addExpense(...) with parsed parameters
          throw UnimplementedError();
      }
    } catch (e) {
      log('Error interpreting message: $e');
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:ai_powered_expense_tracker/database/database.dart';
import 'package:ai_powered_expense_tracker/message_interpretation/function_call_result.dart';
import 'package:ai_powered_expense_tracker/message_interpretation/message_interpret_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../repository.dart';
import 'message_result.dart';

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
                    "`end_date`": {
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

      final functionCall =
          responseBody['candidates'][0]['content']['parts'][0]['functionCall'];

      final text = responseBody['candidates'][0]['content']['parts'][0]['text'];

      if (functionCall != null) {
        if (functionCall['name'] == 'get_expense') {
          final args = functionCall['args'];
          return GetExpensesFunctionCall(
            date: _parsedFromString(args['date'].toString()),
            startDate: _parsedFromString(args['start_date'].toString()),
            endDate: _parsedFromString(args['end_date'].toString()),
            name: args['name'],
          );
        } else  {
          // functionCall['name'] == 'add_expense'
          final args = functionCall['args'];
          return AddExpenseFunctionCall(
            amount: double.tryParse(args['amount'].toString()) ?? 0,
            name: args['name'],
            date: _parsedFromString(args['date'].toString()),
          );
        }
      } else {
        return NoResultFunctionCall(text: text, isError: false);
      }
    } catch (_) {
      rethrow;
    }
  }

  void interpretAndProcess(String message, Repository repository) async {
    try {
      final functionCallResult = await getFunctionCallResult(message);
      switch (functionCallResult) {
        case NoResultFunctionCall():
          {
            final result = functionCallResult;
            messageResultSubject.add(
              NoResultMessageResult(text: result.text, isError: result.isError),
            );
          }
        case GetExpensesFunctionCall():
        case AddExpenseFunctionCall():
          {
            final result = functionCallResult as AddExpenseFunctionCall;
            final expenseData = ExpenseCompanion.insert(
              name: result.name,
              amount: result.amount,
              date: result.date,
            );
            await repository.addExpense(expenseData);
            messageResultSubject.add(
              AddExpenseMessageResult(expense: expenseData),
            );
          }
      }
    } catch (e, st) {
      log('Error interpreting message: $e $st');
    }
  }

  DateTime _parsedFromString(String dateStr) {
    final parts = dateStr.split('.').map((e) => e.trim()).toList();
    if (parts.length != 3) {
      throw MessageInterpretException(
        'Invalid date format. Expected format: dd. mm. yyyy',
      );
    }
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }
}

final messageResultSubject = BehaviorSubject<MessageResult?>.seeded(null);

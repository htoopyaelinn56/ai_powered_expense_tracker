import 'package:ai_powered_expense_tracker/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final appDatabase = AppDatabase();
  runApp(MyApp(appDatabase: appDatabase));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Powered Expense Tracker',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: ChatScreen(appDatabase: appDatabase),
    );
  }
}

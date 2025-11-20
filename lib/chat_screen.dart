import 'package:ai_powered_expense_tracker/database/database.dart';
import 'package:ai_powered_expense_tracker/repository.dart';
import 'package:flutter/material.dart';

import 'message_interpretation/message_interpreter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  late final Repository repository = Repository(widget.appDatabase);
  final messageInterpreter = MessageInterpreter();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Powered Expense Tracker')),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                messageInterpreter.interpretAndProcess(messageController.text);
                messageController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

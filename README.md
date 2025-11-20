# AI Powered Expense Tracker

AI Powered Expense Tracker is a Flutter mobile app that lets you track your expenses using natural language. You can write or speak messages like "Lunch 12.5 on 1. 2. 2025" and the app uses the Gemini API to interpret and store them as structured expenses in a local database.

Runs on **iOS** and **Android**, with your data stored locally on the device.

---

## Features

- **AI-powered expense input**  
  Type natural language messages (e.g. via a chat-like UI) and let Gemini turn them into structured expense records.
- **Manual expense entry**  
  Add or edit expenses directly if you prefer full control.
- **Local, offline-friendly storage**  
  Expenses are stored in a local database on the device.
- **Expense history**  
  Browse previously added expenses.
- **Simple summaries**  
  View your spending over time or by expense name.
- **Privacy-first**  
  Only the text you send for interpretation is sent to Gemini; expense data is otherwise stored locally.

---

## Tech Stack

**App / UI**
- Flutter
- Dart
- Targets: iOS, Android

**AI Integration**
- Google Gemini API (via `https://generativelanguage.googleapis.com`)
- Message interpretation logic in `lib/message_interpretation/message_interpreter.dart`
- Function call result types in `lib/message_interpretation/function_call_result.dart`
- Error types in `lib/message_interpretation/message_interpret_exception.dart`

**Data Layer**
- Repository pattern in `lib/repository.dart`
- Local database and models in:
  - `lib/database/database.dart`
  - `lib/database/database.g.dart`
  - `lib/database/expense.dart`

---

## Getting Started

### Prerequisites

- Flutter SDK (recent stable version)  
  Install instructions: https://docs.flutter.dev/get-started/install
- Dart SDK (bundled with Flutter)
- Platform tooling:
  - **iOS**: Xcode, Cocoapods
  - **Android**: Android Studio or Android SDK, an emulator or physical device
- A **Gemini API key** from Google AI Studio: https://ai.google.dev

### Clone the repository

```bash
git clone <your-repo-url>
cd ai_powered_expense_tracker
```

### Install dependencies

```bash
flutter pub get
```

### Configure environment / API key

This project uses `flutter_dotenv` and expects a `GEMINI_API_KEY` to be available.

1. Create a `.env` file in the project root (next to `pubspec.yaml`):

   ```env
   GEMINI_API_KEY=your_real_gemini_api_key_here
   ```

2. Make sure `.env` is **not** committed to source control (check `.gitignore`).

3. At runtime, `MessageInterpreter` reads this key using `dotenv.env['GEMINI_API_KEY']` and sends it as an `x-goog-api-key` header for Gemini API calls.

Alternatively, you can set the environment variable in your shell (for tools or testing):

```bash
export GEMINI_API_KEY=your_real_gemini_api_key_here
```

> Note: Keep your API key secret. Do not share it in screenshots, commits, or logs.

---

## Running the app

### iOS

From the project root:

```bash
flutter pub get
flutter run -d ios
```

If you run into CocoaPods issues, try:

```bash
cd ios
pod install
cd ..
flutter run -d ios
```

You can also open `ios/Runner.xcworkspace` in Xcode and run the app from there.

### Android

From the project root:

```bash
flutter pub get
flutter run -d android
```

Make sure you have an Android emulator running or a physical device connected with USB debugging enabled.

---

## How the AI Message Interpretation Works

At a high level, the flow looks like this:

1. **User input**  
   The user types a message in the chat UI (see `lib/chat_screen.dart`).

2. **Interpreter builds a Gemini request**  
   - `lib/message_interpretation/message_interpreter.dart` creates a payload for the Gemini API.
   - It defines tool functions like `get_expense` and `add_expense` in the request payload.

3. **Gemini returns a function call**  
   - Gemini responds with a `functionCall` in the `candidates[0].content.parts[0]` field.  
   - The response indicates which function to call (`get_expense` or `add_expense`) and the arguments.

4. **Map to domain result types**  
   - The interpreter reads the function call and maps it to a `FunctionCallResult` implementation from `function_call_result.dart` (e.g., `GetExpensesFunctionCall`, `AddExpenseFunctionCall`, or `NoResultFunctionCall`).

5. **Apply domain logic**  
   - For `AddExpenseFunctionCall`, the app will create/parse an `Expense` (`lib/database/expense.dart`) and persist it via the repository (`lib/repository.dart`) into the local database (`lib/database/database.dart`).
   - For `GetExpensesFunctionCall`, the app queries expenses (e.g. by date range or name) from the repository and shows them in the UI.
   - For `NoResultFunctionCall`, the app can show Gemini's text response directly.

6. **Error handling**  
   - Any issues in parsing or calling the API can be wrapped in a `MessageInterpretException` from `lib/message_interpretation/message_interpret_exception.dart` and logged or surfaced to the user.

This design keeps the Gemini-specific details inside the `MessageInterpreter` while the rest of the app deals with domain-specific types.

---

## Running Tests

Unit tests live under the `test/` directory. For example, repository tests are in `test/repository_test.dart`.

From the project root, run:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/repository_test.dart
```

---

## Roadmap / Ideas

Planned and potential improvements include:

- More advanced analytics (e.g. spending by category, weekly/monthly charts).
- Multi-currency support and automatic currency detection.
- Better error messages and suggestions when Gemini cannot interpret a message.
- Categories, budgets, and alerts when nearing budget limits.
- Secure cloud backup and optional multi-device sync.
- More robust prompt design and support for additional languages/locales.

---

## Contributing

Contributions, bug reports, and feature requests are welcome.

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`.
3. Make your changes and add tests where appropriate.
4. Run `flutter test`.
5. Open a pull request with a clear description of your changes.

---

## License

Add your preferred license here (e.g. MIT, Apache 2.0) and include the corresponding `LICENSE` file in the repository.


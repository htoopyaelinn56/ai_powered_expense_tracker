class MessageInterpretException implements Exception {
  final String message;

  MessageInterpretException(this.message);

  @override
  String toString() => message;
}

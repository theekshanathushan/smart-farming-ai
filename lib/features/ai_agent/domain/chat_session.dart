class ChatSessionSummary {
  final String sessionId;
  final String title;
  final DateTime lastTimestamp;
  final int messageCount;
  final String preview;

  const ChatSessionSummary({
    required this.sessionId,
    required this.title,
    required this.lastTimestamp,
    required this.messageCount,
    required this.preview,
  });
}

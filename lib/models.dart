/**
 * A type of message (influences how it'll be shown)
 */
enum MessageType {
  notification,
  message,
  system,
  empty
}

/**
 *  A message in the chat
 */
class ChatMessage {

  final String message;
  String? source;
  MessageType type;
  int ageInMs = 0;

  ChatMessage({required this.message, this.type = MessageType.message, this.source});

}
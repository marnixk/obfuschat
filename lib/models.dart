import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/chat_renderer.dart';

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

class ChatUser {

  String nick = "person";

}

class ChatContext {
  ChatUser localUser;
  ChatLog log;
  ChatRenderer renderer;

  ChatContext({
    required this.localUser,
    required this.log,
    required this.renderer
  });
}
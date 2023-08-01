import 'package:obfuschat/chat_client.dart';
import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/chat_renderer.dart';
import 'package:obfuschat/chat_server.dart';

/**
 * A type of message (influences how it'll be shown)
 */
enum MessageType {
  notification,
  message,
  system,
  protocol,
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

  /**
   * Initialise data-members
   */
  ChatMessage({
    required this.message,
    this.type = MessageType.message,
    this.source
  });

  /**
   * Convert to JSON map
   */
  Map<String, dynamic> toJson() => {
    "type": this.type.name,
    "source": this.source,
    "message": this.message,
  };

  /**
   * Turn map into ChatMessage instance
   */
  ChatMessage.fromJson(Map<String, dynamic> json)
  :
    type = MessageType.values.firstWhere((msgType) => msgType.name == json['type']),
    source = json['source'],
    message = json['message']
  ;
}

class ChatUser {

  String? nick;

}

class ChatContext {

  ChatUser localUser;
  ChatLog log;
  ChatServer chatServer;
  ChatClient chatClient;
  ChatRenderer? renderer;

  ChatContext({
    required this.localUser,
    required this.log,
    required this.chatServer,
    required this.chatClient,
    this.renderer,
  });
}
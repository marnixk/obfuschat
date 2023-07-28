

import 'dart:async';

import 'models.dart';

class ChatLog {

  /**
   * Stream controller for messaging notifications
   */
  final StreamController<ChatMessage> _controller = StreamController<ChatMessage>.broadcast();

  /**
   * A record of messages
   */
  List<ChatMessage> logs;

  /**
   * Initialise data-members
   */
  ChatLog() : logs = [];

  /**
   * Expose the stream from the controller
   */
  get messageStream => _controller.stream;

  /**
   * Add a chat message
   */
  void addChatMessage(ChatMessage chatMessage) {
    logs.add(chatMessage);
    _controller.add(chatMessage);
  }

  void addMessage(String from, String chat) {
    this.addChatMessage(ChatMessage(message: chat, source: from, type: MessageType.message));
  }

  void addNotification(String notification) {
    this.addChatMessage(ChatMessage(message: notification, type: MessageType.notification));
  }

  void addSystemMessage(String source, String systemMessage) {
    this.addChatMessage(ChatMessage(message: systemMessage, source: source, type: MessageType.system));
  }


  /**
   * Last lines.
   */
  List<ChatMessage> lastLines(int nLines) {

    // enough lines? let's grab some old one.
    if (this.logs.length > nLines) {
      return this.logs.sublist(this.logs.length - nLines);
    }

    List<ChatMessage> emptyLines = [];

    // number of lines that would be missing?
    int nMissing = nLines - this.logs.length;
    for (int i = 0; i < nMissing; ++i) {
      emptyLines.add(ChatMessage(message: "", type: MessageType.empty));
    }

    return [
      ...emptyLines,
      ...this.logs
    ];
  }

}
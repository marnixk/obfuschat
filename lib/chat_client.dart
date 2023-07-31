import 'dart:io';

import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/models.dart';

class ChatClient {

  /**
   * Connection state.
   */
  bool connected = false;

  Socket? client;

  /**
   * Connect to a remote obfuschat server.
   */
  Future<void> connectTo(ChatLog log, String host, int port) async {

    // already connected? skip.
    if (connected) {
      return;
    }


    this.client = await Socket.connect(host, port);
    connected = true;

    this.client!.listen((charList) {
      var message = String.fromCharCodes(charList);
      var msgParts = message.split("\t");

      if (msgParts.length != 3) {
        return;
      }

      ChatMessage chatMsg = ChatMessage(
        source: msgParts[0],
        type: MessageType.values.firstWhere((type) => type.name == msgParts[1]),
        message: msgParts[2]
      );

      log.addChatMessage(chatMsg);
    },
    onError: (err) {
      connected = false;
    },
    onDone: () {
      connected = false;
    });
  }

  sendMessage(ChatMessage chatMsg) {
    if (!connected) {
      return;
    }

    this.client?.writeln(
      "${chatMsg.source}\t"
      "${chatMsg.type.name}\t"
      "${chatMsg.message}"
    );
  }

  /**
   * Disconnect the client.
   */
  disconnect() {
    if (connected) {
      this.client?.close();
    }
  }

}
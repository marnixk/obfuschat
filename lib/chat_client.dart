import 'dart:convert';
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

    this.client!.done.catchError((error) {
      print("An error occurred: $error");
    });

    this.client!.listen((charList) {
      var message = String.fromCharCodes(charList);

      try {
        var jsonMessage = jsonDecode(message);
        var chatMsg = ChatMessage.fromJson(jsonMessage);

        // ping message?
        if (chatMsg.type == MessageType.protocol && chatMsg.message == "ping") {
          var pongMsg = ChatMessage(message: "pong", type: MessageType.protocol, source: "client");
          this.client!.writeln(jsonEncode(pongMsg));
        }

        log.addChatMessage(chatMsg);
      }
      on FormatException catch (err) {
        // do nothing
      }
      catch (err) {
        log.addChatMessage(ChatMessage(type: MessageType.system, message: "$err"));
      }
    },
    onError: (err) {
      connected = false;
    },
    onDone: () {
      connected = false;
    });
  }

  /**
   * Send a message to the server by encoding it to json.
   */
  sendMessage(ChatMessage chatMsg) {
    if (!connected) {
      return;
    }

    this.client?.writeln(jsonEncode(chatMsg));
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
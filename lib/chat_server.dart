import 'dart:io';
import 'dart:typed_data';

import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/models.dart';

/**
 *  Chat server implementation
 */
class ChatServer {

  /**
   * Server active?
   */
  bool active = false;

  int? port;

  List<Socket> activeSockets = [];

  /**
   * Start the server
   */
  Future<void> startListening(ChatLog log, int port) async {
    ServerSocket serverSocket = await ServerSocket.bind('0.0.0.0', port);

    this.port = port;
    this.active = true;

    // server socket start
    serverSocket.listen((socket) {

      activeSockets.add(socket);

      // context
      ChatUser user = ChatUser();

      // handle an incoming socket
      socket.listen((Uint8List data) {

        var messageText = String.fromCharCodes(data);

        // message parts
        List<String> msgParts = messageText.split("\t");

        if (msgParts.length != 3) {
          return;
        }

        // chat message reconstructed
        ChatMessage chatMsg = ChatMessage(
          source: msgParts[0],
          type: MessageType.values.firstWhere((type) => type.name == msgParts[1]),
          message: msgParts[2]
        );

        // add message to log
        log.addChatMessage(chatMsg);

        // broadcast to other users -- they should receive a message as well
        broadcast(chatMsg, socket);
      },
      onError: (err) {
        activeSockets.remove(socket);
      },
      onDone: () {
        activeSockets.remove(socket);
      });
    });
  }

  /**
   * Broadcast to the other active sockets.
   */
  Future<void> broadcast(ChatMessage chatMsg, [Socket? exceptTo]) async {

    if (!this.active) {
      return;
    }

    // send it to all the sockets.
    for (var other in activeSockets) {

      if (other == exceptTo) {
        continue;
      }

      other.writeln(
        "${chatMsg.source}\t"
        "${chatMsg.type.name}\t"
        "${chatMsg.message}"
      );
    }
  }


}
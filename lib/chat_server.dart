import 'dart:convert';
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

    // send a ping message to keep sockets alive.
    _initialisePing();

    // server socket start
    serverSocket.listen((socket) {
      _handleNewConnection(socket, log);
    });
  }

  void _handleNewConnection(Socket socket, ChatLog log) {

    activeSockets.add(socket);

    socket.done.catchError((error) {
      print("Error: $error");
    });

    // handle an incoming socket
    socket.listen((Uint8List data) {

      var messageText = String.fromCharCodes(data);
      try {
        ChatMessage chatMsg = ChatMessage.fromJson(jsonDecode(messageText));

        // show in chat log
        log.addChatMessage(chatMsg);

        // broadcast to other users -- they should receive a message as well
        broadcast(chatMsg, socket);
      }
      on FormatException catch (err) {
        // do nothing
      }
      catch (err) {
        log.addSystemMessage("error", "$err");
      }
    },
    onError: (err) {
      activeSockets.remove(socket);
    },
    onDone: () {
      activeSockets.remove(socket);
    });
  }

  /**
   * Initialise a message ping that sends a 'protocol' message to all active sockets every
   * number of seconds.
   */
  void _initialisePing() {

    var pingMsg = ChatMessage(message: "ping", type: MessageType.protocol, source: "server");
    var jsonPingMsg = jsonEncode(pingMsg);

    // send a ping message to keep sockets alive.
    Stream.periodic(Duration(seconds: 5)).listen((event) {

      // send to each active socket.
      for (var socket in activeSockets) {
        try {
          socket.writeln(jsonPingMsg);
        }
        catch (err) {
          // couldn't write to socket, maybe it closed in between.
        }
      }

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

      other.writeln(jsonEncode(chatMsg));
    }
  }


}
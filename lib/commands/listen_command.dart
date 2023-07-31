
import 'package:obfuschat/models.dart';

import 'command.dart';

/**
 * Connect command implementation. Starts a server.
 */
class ListenCommand implements Command {

  /**
   *
   */
  @override
  bool appliesTo(String line) => line.startsWith("/listen");


  @override
  List<ChatMessage> execute(ChatContext context, String line) {
    var lineParts = line.split(" ");

    if (context.chatServer == null) {
      return <ChatMessage>[];
    }

    // make sure the input is correct
    if (lineParts.length != 2 || int.tryParse(lineParts[1]) == null) {
      return <ChatMessage>[
        ChatMessage(message: ":: '/listen' Requires one parameter, a number between 1 and 65536", type: MessageType.system)
      ];
    }

    // server already running?
    if (context.chatServer!.active) {
      return <ChatMessage>[
        ChatMessage(message: ":: A server is already running on port ${context.chatServer!.port}", type: MessageType.system)
      ];
    }

    // get the port
    int port = int.tryParse(lineParts[1])!;
    context.chatServer!.startListening(context.log, port);

    // started the server, give a response.
    return <ChatMessage>[
      ChatMessage(message: ":: Now listening on $port", type: MessageType.system)
    ];
  }
}
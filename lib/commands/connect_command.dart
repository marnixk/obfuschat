import 'package:obfuschat/commands/command.dart';
import 'package:obfuschat/models.dart';

class ConnectCommand implements Command {

  @override
  bool appliesTo(String line) => line.startsWith("/connect");

  @override
  List<ChatMessage> execute(ChatContext context, String line) {
    List<String> parts = line.split(" ");

    // already a server?
    if (context.chatServer?.active ?? false) {
      return [
        ChatMessage(type: MessageType.system, message: ":: A server is already running.")
      ];
    }

    // not enough parameters?
    if (parts.length != 3) {
      return [
        ChatMessage(type: MessageType.system, message: ":: This command requires two parameters: /connect <host> <port>")
      ];
    }

    // extract parameters
    String host = parts[1];
    int? port = int.tryParse(parts[2]);
    if (port == null) {
      return [
        ChatMessage(type: MessageType.system, message: ":: The port needs to be numeric")
      ];
    }

    // actually connect
    context.chatClient.connectTo(context.log, host, port);

    return [
      ChatMessage(type: MessageType.system, message: ":: Connected to remote server.")
    ];

  }

}
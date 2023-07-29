import 'package:obfuschat/commands/command.dart';
import 'package:obfuschat/models.dart';

class NickCommand implements Command {
  @override
  bool appliesTo(String line) => line.startsWith("/nick ");

  @override
  List<ChatMessage> execute(ChatContext context, String line) {
    List<String> parts = line.split(" ");
    if (parts.length < 2) {
      return [
        ChatMessage(message: ":: Not enough parameters", type: MessageType.system)
      ];
    }

    // change nick name
    context.localUser.nick = parts[1];

    return [
      ChatMessage(message: ":: Changed your nickname to ${parts[1]}", type: MessageType.system)
    ];
  }

}
import 'package:obfuschat/commands/command.dart';
import 'package:obfuschat/models.dart';

class UnknownCommand implements Command {
  @override
  bool appliesTo(String line) {
    return false;
  }

  @override
  List<ChatMessage> execute(ChatContext context, Object line) {
    return <ChatMessage>[
      ChatMessage(message: "Unknown command: $line", type: MessageType.system)
    ];
  }

}
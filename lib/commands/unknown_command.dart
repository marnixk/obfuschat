import 'package:obfuschat/commands/command_base.dart';
import 'package:obfuschat/models.dart';

class UnknownCommand implements Command {
  @override
  bool appliesTo(String line) {
    return false;
  }

  @override
  List<ChatMessage> execute(Object line) {
    return <ChatMessage>[
      ChatMessage(message: "Unknown command: $line", type: MessageType.system)
    ];
  }

}
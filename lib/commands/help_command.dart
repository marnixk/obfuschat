import '../models.dart';
import 'command_base.dart';

/**
 *  Help command
 */
class HelpCommand implements Command {

  /**
   * React to the /help annotation
   */
  @override
  bool appliesTo(String line) => line == "/help";

  /**
   * Return the help
   */
  @override
  List<ChatMessage> execute(String line) {
    ChatMessage toMsg(String text) => ChatMessage(message: text, type: MessageType.system);

    // convert a list of strings with the help message to chat messages
    return <String>[
      "",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⟡ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "  Here are some instructions you can use inside of Obfuschat:",
      "",
      "  /quit - exit the program.",
      "  /nick <name> - set your nick name",
      "  /connect <host> <port> - connect to a host and port ",
      "  /obfuscate start - start obfuscating.",
      "  /obfuscate stop - stop obfuscating.",
      "",
      "  /seed - output information about current seed state.",
      "  /seed generate <filename> <size> - create a seed file with random characters.",
      "  /seed send [filename] - send a seed file to the other party",
      "  /seed use [filename] - start using a seed file",
      "  /seed seek [seed-id] - seek to a particular position in the seed file.",
      "  /seed position - current position in seed file.",
      "",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⟡ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "",
    ].map(toMsg).toList();
  }

}
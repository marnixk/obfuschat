import 'package:obfuschat/commands/connect_command.dart';
import 'package:obfuschat/commands/listen_command.dart';
import 'package:obfuschat/commands/nick_command.dart';
import 'package:obfuschat/commands/unknown_command.dart';

import 'commands/command.dart';
import 'commands/help_command.dart';

class CommandDispatch {

  static List<Command> allCommands = [
    HelpCommand(),
    NickCommand(),
    ListenCommand(),
    ConnectCommand()
  ];

  /**
   * Get the command that can interpret this line.
   */
  Command getCommandForInput(String line) {
    return allCommands.firstWhere(
      (cmd) => cmd.appliesTo(line),
      orElse: () => UnknownCommand()
    );
  }

}
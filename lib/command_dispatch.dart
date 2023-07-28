

import 'package:obfuschat/commands/unknown_command.dart';

import 'commands/command_base.dart';
import 'commands/help_command.dart';

class CommandDispatch {

  static List<Command> allCommands = [
    HelpCommand()
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
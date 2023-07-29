import 'package:obfuschat/command_dispatch.dart';
import 'package:obfuschat/commands/command.dart';
import 'package:obfuschat/commands/help_command.dart';
import 'package:obfuschat/commands/unknown_command.dart';

import 'package:test/test.dart';

void main() {

  test("command dispatch", () {

    var cd = CommandDispatch();
    Command? helpBase = cd.getCommandForInput("/help");
    assert(helpBase != null && helpBase.runtimeType == HelpCommand);

    Command? shouldBeNull = cd.getCommandForInput("/unknown");
    assert(shouldBeNull.runtimeType == UnknownCommand);

  });

}
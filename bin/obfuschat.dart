import 'dart:async';
import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/chat_renderer.dart';
import 'package:obfuschat/command_dispatch.dart';
import 'package:obfuschat/commands/command.dart';
import 'package:obfuschat/models.dart';
import 'package:obfuschat/non_blocking_input.dart';

Console console = Console();
ChatLog log = ChatLog();
ChatRenderer renderer = ChatRenderer(console: console, log: log);
ChatUser localUser = ChatUser();

ChatContext chatContext = ChatContext(
  log: log,
  renderer: renderer,
  localUser: localUser
);

Future<void> addStartInfo(ChatLog log) async {
  var notes = <String>[
    "    ___  _      __                _           _   ",
    "   / _ \\| |__  / _|_   _ ___  ___| |__   __ _| |_ ",
    "  | | | | '_ \\| |_| | | / __|/ __| '_ \\ / _` | __|",
    "  | |_| | |_) |  _| |_| \\__ \\ (__| | | | (_| | |_ ",
    "   \\___/|_.__/|_|  \\__,_|___/\\___|_| |_|\\__,_|\\__|",
    "",
    "  Obfuschat -- if you make it weird enough, they'll never know what you're talking about",
    ""
  ];

  for (var msg in notes) {
    log.addNotification(msg);
    await Future.delayed(Duration(milliseconds: 100));
  }

}

Future<void> chatLoop() async {

  bool running = true;
  var dispatcher = CommandDispatch();
  Console console = Console();

  renderer.start();

  await addStartInfo(log);

  // non-blocking way of reading input from the command line.
  StreamSubscription? strSub;

  strSub = NonBlockingInput().readLine(
      x: 5,
      y: console.windowHeight - 2,
      maxWidth: console.windowWidth - 8,
      continuous: true,

      onKey: (key) {

        // refresh when pressing ctrl-l
        if (key.isControl && key.controlChar == ControlCharacter.ctrlL) {
          renderer.draw();
        }

      },

      onDone: (String messageText, ControlCharacter lastKey) {

        if (messageText.isEmpty) {
          return;
        }

        if (messageText == "/quit") {
          running = false;

          stdin.lineMode = true;
          stdin.echoMode = true;

          strSub!.cancel();
          return;
        }

        // starts with a `/` it must be a command.
        if (messageText[0] == "/") {

          Command command = dispatcher.getCommandForInput(messageText);

          List<ChatMessage> messages = command.execute(chatContext, messageText);
          for (var message in messages) {
            log.addChatMessage(message);
          }

          return;
        }

        // add message to log
        log.addMessage(localUser.nick, messageText);
      },
  );


  while (running) {
    // give some breathing room to other threads
    await Future.delayed(Duration(milliseconds: 500));
  }


  console
    ..resetColorAttributes()
    ..clearScreen()
    ..showCursor()
  ;
  exit(0);

}


void main(List<String> arguments) async {

  await chatLoop();

}


void main2(List<String> arguments) async {

  // isolate that keeps 'data model'
  // chat loop isolate pushes into data model (sendport)
  // socket connections isolate will push into data model as well
  // renderer receives redraw events from data model

  // Documentation:
  // - https://dart.dev/language/concurrency#background-workers
  // - https://github.com/dart-lang/samples/blob/main/isolates/bin/long_running_isolate.dart

  Console().clearScreen();

  var input = NonBlockingInput();

  input.readLine(

    x: 20,
    y: 20,
    maxWidth: 20,

    doneOnControlChars: [
      ControlCharacter.ctrlJ,
      ControlCharacter.tab
    ],

    onDone: (String output, ControlCharacter lastKey) {
      print("\nDone: $output");
      if (lastKey == ControlCharacter.tab) {
        print("Tabbed out");
      }
      if (lastKey == ControlCharacter.ctrlJ) {
        print("Used enter.");
      }
    }
  );

  // while (true) {
  //   print("...");
  //   await Future.delayed(Duration(milliseconds: 100));
  // }


}
import 'dart:async';
import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:obfuschat/chat_log.dart';
import 'package:obfuschat/chat_renderer.dart';
import 'package:obfuschat/non_blocking_input.dart';

Console console = Console();
ChatLog log = ChatLog();
ChatRenderer renderer = ChatRenderer(console: console, log: log);

Future<void> addStartInfo(ChatLog log) async {
  var notes = <String>[
    "  ___  _      __                _           _   ",
    " / _ \\| |__  / _|_   _ ___  ___| |__   __ _| |_ ",
    "| | | | '_ \\| |_| | | / __|/ __| '_ \\ / _` | __|",
    "| |_| | |_) |  _| |_| \\__ \\ (__| | | | (_| | |_ ",
    " \\___/|_.__/|_|  \\__,_|___/\\___|_| |_|\\__,_|\\__|",
    "",
    "Obfuschat -- if you make it weird enough, they'll never know what you're talking about",
    ""
  ];

  for (var msg in notes) {
    log.addNotification(msg);
    await Future.delayed(Duration(milliseconds: 100));
  }

}

Future<void> chatLoop() async {

  bool running = true;
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

        // add message to log
        log.addMessage("ireal", messageText);
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

}


void main(List<String> arguments) async {

  // start the chat loop
  // await Isolate.run(chatLoop);
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
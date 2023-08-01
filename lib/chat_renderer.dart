import 'dart:isolate';

import 'package:dart_console/dart_console.dart';

import 'chat_log.dart';
import 'models.dart';

/**
 * 
 */
class ChatRenderer {

  /**
   * Console to use
   */
  Console console;

  /**
   * Actual chat contents
   */
  ChatLog log;

  /**
   * Initialise chat renderer
   */
  ChatRenderer({
    required this.console,
    required this.log
  });

  Future<void> start() async {

    // when a new message arrives, draw.
    log.messageStream.listen((ChatMessage msg) {
      draw(header: false, inputBox: false);
    });

    // first draw.
    draw();
  }


  draw({bool header = true, bool contents = true, bool inputBox = true}) {

    var console = Console();

    Coordinate? beforeDrawCursor = console.cursorPosition;

    int visibleLines = console.windowHeight - 4;
    List<ChatMessage> lines = this.log.lastLines(visibleLines);

    console
      ..resetColorAttributes()
      ..hideCursor()
      ..clearScreen();
    
    _drawHeader(console);
    _drawContents(lines, console);
    _drawInputBox(console);

    console.cursorPosition = beforeDrawCursor;
    console.showCursor();
  }

  void _drawHeader(Console console) {
    console
      ..cursorPosition = Coordinate(0, 0)

      ..setBackgroundExtendedColor(178)
      ..setForegroundColor(ConsoleColor.black)
      ..writeAligned("Obfuschat", console.windowWidth, TextAlignment.center)

      ..resetColorAttributes()
    ;
  }


  void _drawContents(List<ChatMessage> lines, Console console) {
    int idx = 0;

    console.resetColorAttributes();

    for (var line in lines) {

      // clear line
      console.cursorPosition = Coordinate(idx + 1, 0);
      console.write("".padRight(console.windowWidth));

      // put back to start of line.
      console.cursorPosition = Coordinate(idx + 1, 0);

      // depending on the type of message, show it in a different way.
      switch (line.type) {
        case MessageType.empty:
          break;
    
        case MessageType.message:
          console
            ..setForegroundExtendedColor(214)
            ..write("<${line.source}> ")
            ..setForegroundExtendedColor(255)
            ..write(line.message)
          ;
          break;

        case MessageType.system:
          console
            ..resetColorAttributes()
            ..setForegroundExtendedColor(81)
            ..write(line.message);
          break;
    
        case MessageType.notification:
          console
            ..resetColorAttributes()
            ..setForegroundExtendedColor(190)
            ..write(line.message);
          break;
          
        case MessageType.protocol:
          // console
          //   ..resetColorAttributes()
          //   ..setForegroundExtendedColor(237)
          //   ..write(line.message)
          // ;
          break;
    
      }

      ++idx;

    }
  }

  void _drawInputBox(Console console) {
    console
      ..cursorPosition = Coordinate(console.windowHeight - 3, 0)
      ..setBackgroundExtendedColor(238)
      ..setForegroundExtendedColor(81)
      ..write("".padLeft(console.windowWidth))
      ..write("  > ")
      ..setForegroundExtendedColor(255)
      ..write("".padRight(console.windowWidth - 4))
      ..write("".padLeft(console.windowWidth))
    ;
  }
  /**
   * Get some input
   */
  String? waitForInput() {
    console
        ..showCursor()
        ..cursorPosition = Coordinate(console.windowHeight - 2, 5)
        ..setForegroundExtendedColor(255)
    ;
    String? input = console.readLine();
    return input;
  }
  
}
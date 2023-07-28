import 'dart:async';
import 'dart:io';

import 'package:dart_console/dart_console.dart';

const controlCharEnterKey = ControlCharacter.ctrlJ;
const controlCharTabKey = ControlCharacter.tab;

typedef BeforeDrawFunction = void Function(Console);
typedef AfterDrawFunction = void Function(Console);
typedef OnFinishedInputFunction = void Function(ControlCharacter lastKey);
typedef OnDoneFunction = void Function(String output, ControlCharacter lastKey);
typedef OnKeyFunction = void Function(Key key);
typedef IsDoneFunction = bool Function(Key key);

class NonBlockingInput {

  StreamSubscription readLine({
      String? currentValue,
      int? x, int? y, int? maxWidth,
      bool continuous = false,
      List<ControlCharacter> doneOnControlChars = const <ControlCharacter>[controlCharEnterKey],
      BeforeDrawFunction? beforeDraw,
      AfterDrawFunction? afterDraw,
      required OnDoneFunction onDone
  }) {

    String output = currentValue ?? "";

    /**
     * Initialise variables when they haven't been specified properly.
     */
    var console = Console();
    var cursor = console.cursorPosition!;
    x ??= cursor.col;
    y ??= cursor.row;
    maxWidth ??= console.windowWidth - x - 1;

    // print("X: $x, Y: $y, max width: $maxWidth");

    /**
     * Draw the output
     */
    void drawOutput() {
      if (beforeDraw != null) {
        beforeDraw(console);
      }
      console.cursorPosition = Coordinate(y!, x!);
      console.write("".padRight(maxWidth!));

      console.cursorPosition = Coordinate(y, x);
      console.write(output);

      if (afterDraw != null) {
        afterDraw(console);
      }
    }

    //
    //  Call into [requestInput] and handle on key strokes properly
    //
    return this.requestInput(

      continuous: continuous,

      /**
       * Determine whether the key press makes us done with the input
       */
      isDone: (key) => key.isControl && doneOnControlChars.contains(key.controlChar),

      /**
       * When done callback our own [onDone]
       */
      onDone: (lastKey) {
        onDone(output, lastKey);
        if (continuous) {
          output = "";
          drawOutput();
        }
      },

      /**
       * When a key press is received handle the output string properly.
       */
      onKey: (key) {

        // handle control keys
        if (key.isControl) {
          if (key.controlChar == ControlCharacter.backspace || key.controlChar == ControlCharacter.ctrlH) {
            if (output.isNotEmpty) {
              output = output.substring(0, output.length - 1);
            }
          }
          drawOutput();
          return;
        }

        // it's a normal key.

        // did we limit the max width?
        if (maxWidth != null && output.length < maxWidth) {
          output += key.char;
        }
        // no? just add it.
        else if (maxWidth == null) {
          output += key.char;
        }

        drawOutput();
      }
    );

  }

  /**
   * 
   */
  StreamSubscription requestInput({
    bool continuous = false,
    IsDoneFunction? isDone,
    OnKeyFunction? onKey,
    OnFinishedInputFunction? onDone
  }) {

    stdin
      ..echoMode = false
      ..lineMode = false
    ;

    StreamSubscription? stdinSub;

    // subscribe to stdin
    stdinSub = stdin.listen((List<int> codes) {

      Key key = interpretKey(codes);

      if (onKey != null) {
        onKey(key);
      }

      // done? stop subscription
      if (isDone != null && isDone(key)) {

        if (!continuous) {
          stdinSub!.cancel();
        }

        if (onDone != null) {
          onDone(key.controlChar);
        }
      }
    });

    return stdinSub;
  }


  ///
  /// NOTE: From the amazing "dart_console" package to interpret incoming keycodes.
  ///
  /// Reads a single key from the input, including a variety of control
  /// characters.
  ///
  /// Keys are represented by the [Key] class. Keys may be printable (if so,
  /// `Key.isControl` is `false`, and the `Key.char` property may be used to
  /// identify the key pressed. Non-printable keys have `Key.isControl` set
  /// to `true`, and if so the `Key.char` property is empty and instead the
  /// `Key.controlChar` property will be set to a value from the
  /// [ControlCharacter] enumeration that describes which key was pressed.
  ///
  /// Owing to the limitations of terminal key handling, certain keys may
  /// be represented by multiple control key sequences. An example showing
  /// basic key handling can be found in the `example/command_line.dart`
  /// file in the package source code.
  Key interpretKey(List<int> codes) {

    int getCode(int pos) {
      return codes.length > pos? codes[pos] : -1;
    }

    Key key;
    int charCode;
    var codeUnit = getCode(0);

    if (codeUnit >= 0x01 && codeUnit <= 0x1a) {
      // Ctrl+A thru Ctrl+Z are mapped to the 1st-26th entries in the
      // enum, so it's easy to convert them across
      key = Key.control(ControlCharacter.values[codeUnit]);
    }
    else if (codeUnit == 0x1b) {
      // escape sequence (e.g. \x1b[A for up arrow)
      key = Key.control(ControlCharacter.escape);

      final escapeSequence = <String>[];

      charCode = getCode(1);
      if (charCode == -1) {
        return key;
      }
      escapeSequence.add(String.fromCharCode(charCode));

      if (charCode == 127) {
        key = Key.control(ControlCharacter.wordBackspace);
      } else if (escapeSequence[0] == '[') {
        charCode = getCode(1);
        if (charCode == -1) {
          return key;
        }
        escapeSequence.add(String.fromCharCode(charCode));

        switch (escapeSequence[1]) {
          case 'A':
            key.controlChar = ControlCharacter.arrowUp;
            break;
          case 'B':
            key.controlChar = ControlCharacter.arrowDown;
            break;
          case 'C':
            key.controlChar = ControlCharacter.arrowRight;
            break;
          case 'D':
            key.controlChar = ControlCharacter.arrowLeft;
            break;
          case 'H':
            key.controlChar = ControlCharacter.home;
            break;
          case 'F':
            key.controlChar = ControlCharacter.end;
            break;
          default:
            if (escapeSequence[1].codeUnits[0] > '0'.codeUnits[0] &&
                escapeSequence[1].codeUnits[0] < '9'.codeUnits[0]) {
              charCode = getCode(2);
              if (charCode == -1) {
                return key;
              }
              escapeSequence.add(String.fromCharCode(charCode));
              if (escapeSequence[2] != '~') {
                key.controlChar = ControlCharacter.unknown;
              } else {
                switch (escapeSequence[1]) {
                  case '1':
                    key.controlChar = ControlCharacter.home;
                    break;
                  case '3':
                    key.controlChar = ControlCharacter.delete;
                    break;
                  case '4':
                    key.controlChar = ControlCharacter.end;
                    break;
                  case '5':
                    key.controlChar = ControlCharacter.pageUp;
                    break;
                  case '6':
                    key.controlChar = ControlCharacter.pageDown;
                    break;
                  case '7':
                    key.controlChar = ControlCharacter.home;
                    break;
                  case '8':
                    key.controlChar = ControlCharacter.end;
                    break;
                  default:
                    key.controlChar = ControlCharacter.unknown;
                }
              }
            } else {
              key.controlChar = ControlCharacter.unknown;
            }
        }
      }
      else if (escapeSequence[0] == 'O') {
        charCode = getCode(1);
        if (charCode == -1) {
          return key;
        }
        escapeSequence.add(String.fromCharCode(charCode));
        assert(escapeSequence.length == 2);
        switch (escapeSequence[1]) {
          case 'H':
            key.controlChar = ControlCharacter.home;
            break;
          case 'F':
            key.controlChar = ControlCharacter.end;
            break;
          case 'P':
            key.controlChar = ControlCharacter.F1;
            break;
          case 'Q':
            key.controlChar = ControlCharacter.F2;
            break;
          case 'R':
            key.controlChar = ControlCharacter.F3;
            break;
          case 'S':
            key.controlChar = ControlCharacter.F4;
            break;
          default:
        }
      } else if (escapeSequence[0] == 'b') {
        key.controlChar = ControlCharacter.wordLeft;
      } else if (escapeSequence[0] == 'f') {
        key.controlChar = ControlCharacter.wordRight;
      } else {
        key.controlChar = ControlCharacter.unknown;
      }
    } else if (codeUnit == 0x7f) {
      key = Key.control(ControlCharacter.backspace);
    } else if (codeUnit == 0x00 || (codeUnit >= 0x1c && codeUnit <= 0x1f)) {
      key = Key.control(ControlCharacter.unknown);
    } else {
      // assume other characters are printable
      key = Key.printable(String.fromCharCode(codeUnit));
    }
    return key;
  }


}

import 'package:obfuschat/models.dart';

/**
 * The interface each command should implement.
 */
abstract class Command {

  /**
   * Determine whether this command applies to the text
   */
  bool appliesTo(String line);

  /**
   *  Execute the command and return one or more messages.
   */
  List<ChatMessage> execute(String line);

}
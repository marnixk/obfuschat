import 'dart:convert';

import 'package:obfuschat/models.dart';
import 'package:test/test.dart';

void main() {
  test("json encoding", () {

    ChatMessage msg = ChatMessage(message: "Something", type: MessageType.system, source: "ireal");
    var json = jsonEncode(msg);
    var rehydratedMsg = ChatMessage.fromJson(jsonDecode(json));

    print("json: $json, rehydrated: $rehydratedMsg");


  });
}
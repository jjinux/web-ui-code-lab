library application;

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'chat_connection.dart';
import 'chat_window.dart';
import 'username_input.dart';
import 'message_input.dart';

const connectionUrl = "ws://127.0.0.1:1337/ws";
ChatConnection chatConnection;
@observable ChatWindowComponent chatWindow;
@observable UsernameInputComponent usernameInput;
@observable MessageInputComponent messageInput;

Future init() {
  // The Web Components aren't ready immediately in index.html's main.
  return new Future.delayed(0, () {
    // xtag is how you get to the Dart object.
    chatWindow = query("#chat-window").xtag;
    usernameInput = query("#username-input").xtag;
    messageInput = query("#message-input").xtag;

    chatWindow.displayNotice("web component connected");
    chatConnection = new ChatConnection(connectionUrl);
  })
  .catchError((e) => print("Problem initing app: $e"));   
}
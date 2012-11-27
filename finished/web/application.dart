library application;

import 'dart:html';
import 'dart:isolate' show Timer;
import 'package:web_components/web_components.dart';
import 'chat_connection.dart';
import 'out/chat_window.html.dart';
import 'out/username_input.html.dart';
import 'out/message_input.html.dart';

const connectionUrl = "ws://127.0.0.1:1337/ws";
ChatConnection chatConnection;
ChatWindowComponent chatWindow;
UsernameInputComponent usernameInput;
MessageInputComponent messageInput;

init() {
  // The Web Components aren't ready immediately in index.html's main.
  new Timer(0, (timer) {
    
    // xtag is how you get to the Dart object.
    chatWindow = query("#chat-window").xtag;
    usernameInput = query("#username-input").xtag;
    messageInput = query("#message-input").xtag;

    chatWindow.displayNotice("web component connected");
    chatConnection = new ChatConnection(connectionUrl);
  });   
}
library application;

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'chat_window.dart';

@observable ChatWindowComponent chatWindow;

Future init() {
  // The Web Components aren't ready immediately in index.html's main.
  return new Future.delayed(0, () {
    
    // xtag is how you get to the Dart object.
    chatWindow = query("#chat-window").xtag;
    chatWindow.displayNotice("web component connected");
  })
  .catchError((e) => print("Problem initing app: $e"));   
}
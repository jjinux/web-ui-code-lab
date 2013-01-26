library application;

import 'dart:html';
import 'dart:async' show Timer;
import 'package:web_ui/web_ui.dart';
import 'out/chat_window.html.dart';

ChatWindowComponent chatWindow;

init() {
  // The Web Components aren't ready immediately in index.html's main.
  new Timer(0, (timer) {
    
    // xtag is how you get to the Dart object.
    chatWindow = query("#chat-window").xtag;
    chatWindow.displayNotice("web component connected");
    
    dispatch();
  });   
}
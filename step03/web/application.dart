library application;

import 'dart:html';
import 'dart:isolate' show Timer;
import 'package:web_components/web_components.dart';
import 'out/chat_window.html.dart';

class Application {
  ChatWindowComponent chatWindow;
  
  Application() {
    // The Web Components aren't ready immediately in index.html's main.
    new Timer(0, (timer) {
      
      // xtag is how you get to the Dart object.
      chatWindow = query("#chat-window").xtag;
      chatWindow.displayNotice("web component connected");
    });   
  }
}

Application _app;
get app {
  if (_app == null) _app = new Application();
  return _app;
}
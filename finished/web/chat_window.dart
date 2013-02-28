library chat_window;

import 'package:web_ui/web_ui.dart';

class ChatWindowComponent extends WebComponent {
  @observable
  String chatWindowText = '';
  
  displayMessage(String from, String msg) {
    _display("$from: $msg\n");
  }

  displayNotice(String notice) {
    _display("[system]: $notice\n");
  }

  _display(String str) {
    chatWindowText = "${chatWindowText}${str}";
  }
}

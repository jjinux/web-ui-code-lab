library message_input;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'application.dart' as app;

class MessageInputComponent extends WebComponent {
  @observable
  String message = "";

  void sendMessage() {
    app.chatConnection.send(app.usernameInput.username, message);
    app.chatWindow.displayMessage(app.usernameInput.username, message);
    message = '';
  }

  bool get sendDisabled => (app.usernameInput == null ||
                            app.usernameInput.username == null ||
                            app.usernameInput.username.isEmpty ||
                            app.messageInput == null ||
                            app.messageInput.message == null ||
                            app.messageInput.message.isEmpty);
}

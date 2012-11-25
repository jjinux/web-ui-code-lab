library chat_connection;

import 'dart:html';
import 'dart:json';
import 'dart:isolate' show Timer;
import 'application.dart';

class ChatConnection {
  Application app;
  WebSocket webSocket;
  String url;

  ChatConnection(this.app, this.url) {
    _init();
  }

  send(String from, String message) {
    var encoded = JSON.stringify({'f': from, 'm': message});
    _sendEncodedMessage(encoded);
  }

  _receivedEncodedMessage(String encodedMessage) {
    Map message = JSON.parse(encodedMessage);
    if (message['f'] != null) {
      app.chatWindow.displayMessage(message['f'], message['m']);
    }
  }

  _sendEncodedMessage(String encodedMessage) {
    if (webSocket != null && webSocket.readyState == WebSocket.OPEN) {
      webSocket.send(encodedMessage);
    } else {
      print('WebSocket not connected, message $encodedMessage not sent');
    }
  }

  _init([int retrySeconds = 2]) {
    bool encounteredError = false;
    app.chatWindow.displayNotice("connecting to web socket");
    webSocket = new WebSocket(url);

    scheduleReconnect() {
      app.chatWindow.displayNotice('web socket closed, retrying in $retrySeconds seconds');
      if (!encounteredError) {
        new Timer(1000 * retrySeconds, (timer) => _init(retrySeconds * 2));
      }
      encounteredError = true;
    }

    webSocket.on.open.add((e) => app.chatWindow.displayNotice('web socket connected'));
    webSocket.on.close.add((e) => scheduleReconnect());
    webSocket.on.error.add((e) => scheduleReconnect());

    webSocket.on.message.add((MessageEvent e) {
      print('received message ${e.data}');
      _receivedEncodedMessage(e.data);
    });
  }
}
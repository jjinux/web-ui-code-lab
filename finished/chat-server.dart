library chatserver;

import 'dart:io';
import 'dart:isolate';
import 'file-logger.dart' as log;
import 'server-utils.dart';

class StaticFileHandler {
  final String basePath;

  StaticFileHandler(this.basePath);

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.outputStream.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request, HttpResponse response) {
    final String path = request.path == '/' ? '/index.html' : request.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(response);
          } else {
            file.openInputStream().pipe(response.outputStream);
          }
        });
      } else {
        _send404(response);
      }
    });
  }
}

class ChatHandler {

  Set<WebSocketConnection> webSocketConnections;

  ChatHandler(String basePath) : webSocketConnections = new Set<WebSocketConnection>() {
    log.initLogging('${basePath}/chat-log.txt');
  }

  // closures!
  onOpen(WebSocketConnection conn) {
    print('new ws conn');
    webSocketConnections.add(conn);

    conn.onClosed = (int status, String reason) {
      print('conn is closed');
      webSocketConnections.remove(conn);
    };

    conn.onMessage = (message) {
      print('new ws msg: $message');
      webSocketConnections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => connection.send(message));
        }
      });
      time('send to isolate', () => log.log(message));
    };
  }
}

runServer(String basePath, int port) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new ChatHandler(basePath).onOpen;

  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', port);
  print('listening for connections on $port');
}

main() {
  var script = new File(new Options().script);
  var directory = script.directorySync();
  runServer("${directory.path}/client", 1337);
}

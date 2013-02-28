library chatserver;

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import '../lib/file_logger.dart' as log;
import '../lib/server_utils.dart';

class StaticFileHandler {
  final String basePath;

  StaticFileHandler(this.basePath);

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request) {
    final String path =
        request.uri.path == '/' ? '/index.html' : request.uri.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(request.response);
          } else {
            file.openRead().pipe(request.response)
              .catchError((e) => print(e));
          }
        });
      } else {
        _send404(request.response);
      }
    });
  }
}

class ChatHandler {
  Set<WebSocket> webSocketConnections = new Set<WebSocket>();

  ChatHandler(String basePath, String logFile) {
    log.initLogging(logFile);
  }

  // closures!
  onConnection(WebSocket conn) {
    void onMessage(message) {
      print('new ws msg: $message');
      webSocketConnections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => connection.send(message));
        }
      });
      time('send to isolate', () => log.log(message));
    }
    
    print('new ws conn');
    webSocketConnections.add(conn);
    conn.listen((event) {
      if (event is MessageEvent) {
        onMessage(event.data);
      } else if (event is CloseEvent) {
        print('conn is closed');
        webSocketConnections.remove(conn);
      }
    },
    onError: (error) => webSocketConnections.remove(conn),
    onDone: () => webSocketConnections.remove(conn));


  }
}

runServer(String basePath, String logFile, {int port}) {
  ChatHandler chatHandler = new ChatHandler(basePath, logFile);
  StaticFileHandler fileHandler = new StaticFileHandler(basePath);
  
  HttpServer.bind('127.0.0.1', port)
    .then((HttpServer server) {
      print('listening for connections on $port');
      
      var sc = new StreamController();
      sc.stream.transform(new WebSocketTransformer()).listen(chatHandler.onConnection);

      server.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          sc.add(request);
        } else {
          fileHandler.onRequest(request);
        }
      });
    },
    onError: (error) => print("Error starting HTTP server: $error"));
}

main() {
  var script = new File(new Options().script);
  var directory = script.directorySync();
  var basePath = directory.path.replaceFirst(new RegExp(r"bin$"), "web");  // No .. allowed
  var logFile = "${directory.path}/../chat.log";
  runServer(basePath, logFile, port: 1337);
}
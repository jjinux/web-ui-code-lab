library server_utils;

import 'dart:isolate';

time(msg, callback()) {
  var sw = new Stopwatch();
  sw.start();
  callback();
  sw.stop();
  print('Timing for $msg: ${sw.elapsedMicroseconds} us');
}

/// Run the callback on the event loop at the next opportunity.
queue(callback()) {
  new Timer(0, (t) => callback());
}
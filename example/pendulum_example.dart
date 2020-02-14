import 'package:pendulum/pendulum.dart';

void main() async {
  var task = Task((List x) {
    return 'Simple process!';
  }, []);
  var task2 = Task((List x) {
    return 'Delayed process!';
  }, []);
  var task3 = Task((List x) {
    return 'Repeated process!';
  }, []);
  var watch = Stopwatch();

  // Simple process and listen.
  task.process().listen((var data) {
    print(data);
  });

  // Process after a delay of 5 seconds.
  watch.start();
  task2.processAfter(Duration(seconds: 5)).listen((var data) {
    print(data);
    watch.stop();
    print(watch.elapsedMilliseconds);
  });

  await Future.delayed(Duration(seconds: 10));

  // Repeatedly process every 5 seconds for 20 seconds.
  watch.reset();
  watch.start();
  task3
      .repeatIntervalFor(Duration(seconds: 20), Duration(seconds: 5))
      .listen((var data) {
        print(data);
        print(watch.elapsedMilliseconds);
      });
}

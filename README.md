# Pendulum

A library for task-scheduling in Dart. Exports a Task class that returns Streams,
with a number of versatile options to customize how Tasks are run.

Tasks take a Function (and a corresponding List argument) and run them 
asynchronously on a number of triggers. All methods return Streams, because of
their versatility: Streams can be listened, canceled, or converted to other types.
 
Methods take inspiration from [Quartz Scheduler][quartz].

[quartz]: http://www.quartz-scheduler.org/documentation/2.4.0-SNAPSHOT/introduction.html#features

## Usage

A (very) simple usage example:

```dart
import 'package:pendulum/pendulum.dart';

void main() async {
  var task = Task<String>((List args) {
    return 'Simple process!';
  }, []);
  var task2 = Task<String>((List args) {
    return 'Delayed process!';
  }, []);
  var task3 = Task<String>((List args) {
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
```

This is just the start of the features of Pendulum. To see all the methods and triggers, 
check out the API reference.

## Simulated Tasks

Testing Pendulum can be a pain if you're using Tasks with DateTime arguments, because you 
have to wait for the DateTime to be reached to test. My solution to this problem is 
SimulatedTask:

- Simulated Task uses a provided DateTime instead of DateTime.now()
- You can 'fast-forward' to any point in time that you want using setNow(DateTime arg)

This is obviously an imperfect solution, and I'm welcome to suggestions as to alternatives.

## Partners in Crime

While Pendulum works fine all on its own, there are some packages that can enhance its
functionality. A few of them are listed below:

- [RxDart][rx]
    * Library for Stream extensions.
    * Can be used to enhance processor methods
- [Instant][inst]
    * Library for DateTime manipulation.
    * Many Pendulum triggers involve DateTimes
    * Can be used to adjust for timezones
- [Isolate][iso]
    * Library for isolate management.
    * While Pendulum runs async, one isolate might not be able to handle all the tasks.
    * Using the isolate load_balancer class to run tasks could thus save CPU.
    
[rx]: https://pub.dev/packages/rxdart
[inst]: https://pub.dev/packages/instant
[iso]: https://pub.dev/packages/isolate

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

---

###### This package and its contents are subject to the terms of the Mozilla Public License, v. 2.0.
###### © 2019 Aditya Kishore
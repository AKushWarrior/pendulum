import 'dart:math';

/// Wrapper for a Function(List) with the corresponding List of arguments.
///
/// Processes the inner function in a variety of manners with a variety of triggers.
class Task<T> {
  T Function(List) inner;
  List arguments;

  Task(T Function(List arguments) function, List arguments) {
    arguments = arguments;
    inner = function;
  }

  /// Executes [inner] and yields the result in a Stream.
  Stream<T> process() async* {
    yield inner(arguments);
  }

  /// Not for external use, but this just returns the current date.
  DateTime now() {return DateTime.now();}

  /// Executes [inner] after a delay and yields the result in a Stream.
  Stream<T> processAfter(Duration delay) async* {
    final target =
        DateTime.now().millisecondsSinceEpoch + delay.inMilliseconds.toDouble();
    var delta = target - DateTime.now().millisecondsSinceEpoch;
    while (delta > 0) {
      delta = target - DateTime.now().millisecondsSinceEpoch;
      if (pow(delta, 0.6).isNaN) break;
      await Future.delayed(Duration(milliseconds: pow(delta, 0.6).round()));
    }
    yield inner(arguments);
  }

  /// Executes [inner] at the given time and yields the result in a Stream.
  Stream<T> processAt(DateTime time) async* {
    final target = time.difference(now()).inMilliseconds;
    var delta = target - now().millisecondsSinceEpoch;
    while (delta > 0) {
      delta = target - now().millisecondsSinceEpoch;
      await Future.delayed(Duration(milliseconds: pow(delta, 0.6).round()));
    }
    yield inner(arguments);
  }

  /// Repeats [inner] indefinitely and yields results.
  Stream<T> repeat() async* {
    while (true) {
      yield inner(arguments);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, and
  /// yields the results.
  Stream<T> repeatInterval(Duration interval) async* {
    while (true) {
      yield inner(arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition until
  /// [length] has elapsed, and yields the results.
  Stream<T> repeatIntervalFor(Duration length, Duration interval) async* {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < length) {
      yield inner(arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition until
  /// [time], and yields the results.
  Stream<T> repeatIntervalUntil(DateTime time, Duration interval) async*{
    while (DateTime.now().millisecondsSinceEpoch < time.millisecondsSinceEpoch) {
      yield inner(arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeatedly process [inner] every [interval] until [length] has elapsed, if
  /// the current weekday, date, hour, minute, or second is in the respective
  /// array.
  Stream<T> repeatWithOptions(
      {Duration length,
      Duration interval,
      Iterable<int> weekdays,
      Iterable<int> dates,
      Iterable<int> hours,
      Iterable<int> minutes,
      Iterable<int> seconds}) async* {
    length ??= Duration(days: 4294967295);
    interval ??= Duration(seconds: 1);
    weekdays ??= [];
    dates ??= [];
    hours ??= [];
    minutes ??= [];
    seconds ??= [];
    final start = DateTime.now();
    while (DateTime.now().difference(start) < length) {
      var nowDate = now();
      if (weekdays.contains(nowDate.weekday) ||
          dates.contains(nowDate.day) ||
          hours.contains(nowDate.hour) ||
          minutes.contains(nowDate.minute) ||
          seconds.contains(nowDate.second)) yield inner(arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current weekday is in [weekdays].
  ///
  /// Correspondence goes: Mon. == 1, Tues. == 2, ... Sun. == 7
  Stream<T> processOnWeekdays(Iterable<int> weekdays, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (weekdays.contains(now().weekday)) yield inner(arguments);
      await Future.delayed(target.difference(now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current day of the month is in [dates].
  Stream<T> processOnDates(Iterable<int> dates, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (dates.contains(now().day)) yield inner(arguments);
      await Future.delayed(target.difference(now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current hour of the day is in [hours].
  Stream<T> processOnHours(Iterable<int> hours, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (hours.contains(now().hour)) yield inner(arguments);
      await Future.delayed(target.difference(now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current minute of the hour is in [minutes].
  Stream<T> processOnMinutes(Iterable<int> minutes, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (minutes.contains(now().minute)) yield inner(arguments);
      await Future.delayed(target.difference(now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current second of the minute is in [seconds].
  Stream<T> processOnSeconds(Iterable<int> seconds, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (seconds.contains(now().second)) yield inner(arguments);
      await Future.delayed(target.difference(now()));
    }
  }
}

/// Child class of [Task] for testing purposes.
///
/// Allows you to set the DateTime that Task uses as "now".
class SimulatedTask<T> extends Task<T> {
  DateTime nowDT;

  /// Set the DateTime that will be used as "now" by this Task's methods.
  void setNow (DateTime simulated) {
    nowDT = simulated;
  }

  /// Get the DateTime currently used as now.
  @override
  DateTime now() => nowDT;

  /// Create a simulated task with a DateTime to use as now.
  SimulatedTask (T Function(List arguments) function, List arguments, DateTime sim) : super(function, arguments) {
    nowDT = sim;
  }

  @override
  void noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

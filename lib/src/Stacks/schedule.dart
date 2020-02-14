import 'dart:math';

class Task {
  Function(List) _inner;
  List _arguments;

  /// Get the Function of this task.
  Function(List) get inner => _inner;

  Task(Function(List arguments) function, List arguments) {
    _arguments = arguments;
    _inner = function;
  }

  /// Executes [inner] and yields the result in a Stream.
  Stream process() async* {
    yield _inner(_arguments);
  }

  /// Executes [inner] after a delay and yields the result in a Stream.
  Stream processAfter(Duration delay) async* {
    final target =
        DateTime.now().millisecondsSinceEpoch + delay.inMilliseconds.toDouble();
    var delta = target - DateTime.now().millisecondsSinceEpoch;
    while (delta > 0) {
      delta = target - DateTime.now().millisecondsSinceEpoch;
      if (pow(delta, 0.6).isNaN) break;
      await Future.delayed(Duration(milliseconds: pow(delta, 0.6).round()));
    }
    yield _inner(_arguments);
  }

  /// Executes [inner] at the given time and yields the result in a Stream.
  Stream processAt(DateTime time) async* {
    final target = time.difference(DateTime.now()).inMilliseconds;
    var delta = target - DateTime.now().millisecondsSinceEpoch;
    while (delta > 0) {
      delta = target - DateTime.now().millisecondsSinceEpoch;
      await Future.delayed(Duration(milliseconds: pow(delta, 0.6).round()));
    }
    yield _inner(_arguments);
  }

  /// Repeats [inner] indefinitely and yields results.
  Stream repeat() async* {
    while (true) {
      yield _inner(_arguments);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, and
  /// yields the results.
  Stream repeatInterval(Duration interval) async* {
    while (true) {
      yield _inner(_arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition until
  /// [length] has elapsed, and yields the results.
  Stream repeatIntervalFor(Duration length, Duration interval) async* {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < length) {
      yield _inner(_arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition until
  /// [time], and yields the results.
  Stream repeatIntervalUntil(DateTime time, Duration interval) async*{
    while (DateTime.now().millisecondsSinceEpoch < time.millisecondsSinceEpoch) {
      yield _inner(_arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeatedly process [inner] every [interval] until [length] has elapsed, if
  /// the current weekday, date, hour, minute, or second is in the respective
  /// array.
  Stream repeatWithOptions(
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
      var now = DateTime.now();
      if (weekdays.contains(now.weekday) ||
          dates.contains(now.day) ||
          hours.contains(now.hour) ||
          minutes.contains(now.minute) ||
          seconds.contains(now.second)) yield _inner(_arguments);
      await Future.delayed(interval);
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current weekday is in [weekdays].
  ///
  /// Correspondence goes: Mon. == 1, Tues. == 2, ... Sun. == 7
  Stream processOnWeekdays(Iterable<int> weekdays, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (weekdays.contains(DateTime.now().weekday)) yield _inner(_arguments);
      await Future.delayed(target.difference(DateTime.now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current day of the month is in [dates].
  Stream processOnDates(Iterable<int> dates, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (dates.contains(DateTime.now().day)) yield _inner(_arguments);
      await Future.delayed(target.difference(DateTime.now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current hour of the day is in [hours].
  Stream processOnHours(Iterable<int> hours, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (hours.contains(DateTime.now().hour)) yield _inner(_arguments);
      await Future.delayed(target.difference(DateTime.now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current minute of the hour is in [minutes].
  Stream processOnMinutes(Iterable<int> minutes, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (minutes.contains(DateTime.now().minute)) yield _inner(_arguments);
      await Future.delayed(target.difference(DateTime.now()));
    }
  }

  /// Repeat [inner] indefinitely with [interval] between each repetition, if
  /// the current second of the minute is in [seconds].
  Stream processOnSeconds(Iterable<int> seconds, Duration interval) async* {
    while (true) {
      var target = DateTime.now().add(interval);
      if (seconds.contains(DateTime.now().second)) yield _inner(_arguments);
      await Future.delayed(target.difference(DateTime.now()));
    }
  }
}

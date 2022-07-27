// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_utilities/src/data_structures.dart';
import 'package:remove_emoji/remove_emoji.dart';

// Project imports:
import 'package:flutter_utilities/src/core_classes.dart';

extension IterableUtils<E> on Iterable<E> {
  Map<E, X> presenceMap<X>({
    required X defaultValue,
    required X presenceValue,
    required Iterable<E> elements,
  }) {
    final Map<E, bool> presence = Map<E, bool>.fromEntries(
      elements.map<MapEntry<E, bool>>(
        (e) => MapEntry<E, bool>(e, true),
      ),
    );

    return Map<E, X>.fromEntries(
      map<MapEntry<E, X>>(
        (e) => MapEntry<E, X>(
          e,
          (presence[e] ?? false) ? presenceValue : defaultValue,
        ),
      ),
    );
  }

  Map<E, int> priorityMap() {
    final int count = length;
    final Map<E, int> result = {};
    for (int i = 0; i < count; ++i) {
      result.addAll({
        elementAt(i): i,
      });
    }
    return result;
  }

  bool isAnagramOf(Iterable<E> other) =>
      length == other.length &&
      (Set<E>.from(this)..removeAll(other)).isEmpty &&
      (Set<E>.from(other)..removeAll(this)).isEmpty;
}

extension MapUtils<K, V> on Map<K, V> {
  Map<K, V> filter(List<K> keys) {
    final Map<K, V> result = {};
    for (final K key in keys) {
      if (containsKey(key)) {
        result.addAll({
          key: this[key] as V,
        });
      }
    }
    return result;
  }

  Map<K, V> filterWhere(bool Function(K key, V value) test) {
    final Map<K, V> result = {};
    forEach((key, value) {
      if (test(key, value)) {
        result.addAll({key: value});
      }
    });
    return result;
  }

  Map<K, V> filterOutWhere(bool Function(K key, V value) test) {
    final Map<K, V> result = {};
    forEach((key, value) {
      if (!test(key, value)) {
        result.addAll({key: value});
      }
    });
    return result;
  }

  void override(Map<K, V> newValues) {
    newValues.forEach((key, value) {
      this[key] = value;
    });
  }

  Map<K, V> filterOut(List<K> keys) {
    final Map<K, V> result = {};
    for (final K key in keys) {
      if (!containsKey(key)) {
        result.addAll({
          key: this[key] as V,
        });
      }
    }
    return result;
  }

  Map<K, V> difference(
    Map<K, V> other, {
    bool ignoreNewFields = false,
  }) {
    final Map<K, V> result = {};
    other.forEach((key, value) {
      if ((containsKey(key) || !ignoreNewFields) && (this[key] != value)) {
        result.addAll({
          key: value,
        });
      }
    });
    return result;
  }

  void removeAll(List<K> keys) {
    for (final K x in keys) {
      remove(x);
    }
  }

  K keyWhere(
    bool Function(MapEntry<K, V> entry) test, [
    K Function()? onNotFound,
  ]) {
    for (final MapEntry<K, V> x in entries) {
      if (test(x)) {
        return x.key;
      }
    }
    if (onNotFound != null) {
      return onNotFound();
    }
    throw "Key Not Found";
  }

  List<K> keysWhere(bool Function(MapEntry<K, V>) test) {
    final List<K> result = [];
    for (final MapEntry<K, V> x in entries) {
      if (test(x)) {
        result.add(x.key);
      }
    }
    return result;
  }

  Map<V, K> switchSides() => Map<V, K>.fromIterables(values, keys);

  /*static Map<K, V> deepCopyValuesOnlyFrom(Map other) {
    final Map<K, V> result = {};
    other.forEach(
      (key, value) {
        if (value is Map) {
          result.addAll(
            {
              key as K: deepCopyValuesOnlyFrom(value as Map<K, V>) as V,
            },
          );
        } else if (value is List) {
          result.addAll(
            {
              key as K: deepCopyValuesOnlyFrom(value as Map<K, V>) as V,
            },
          );
        } else {
          result.addAll(
            {
              key as K: value as V,
            },
          );
        }
      },
    );
    return result;
  }*/
}

extension ListUtils<E> on List<E> {
  /*static List<E> deepCopyValuesOnlyFrom(List other) {
    final List<E> result = [];
    for (final x in other) {
      if (x is Map) {
        result.add(MapUtils.deepCopyValuesOnlyFrom(x) as E);
      } else if (x is List<E>) {
        result.add(deepCopyValuesOnlyFrom(x) as E);
      } else {
        result.add(x as E);
      }
    }
    return result;
  }*/

  /*bool isAnagramOf(List<E> other) =>
      length == other.length &&
      (Set<E>.from(this)..removeAll(other)).isEmpty &&
      (Set<E>.from(other)..removeAll(this)).isEmpty;*/

  int indexOfExcept(
    E element,
    List<int> exceptions, [
    int start = 0,
  ]) {
    for (int i = start; i < length; ++i) {
      if (this[i] == element && !exceptions.contains(i)) {
        return i;
      }
    }
    return -1;
  }

  int indexWhereExcept(
    bool Function(E element) test,
    List<int> exceptions, [
    int start = 0,
  ]) {
    for (int i = start; i < length; ++i) {
      if (test(this[i]) && !exceptions.contains(i)) {
        return i;
      }
    }
    return -1;
  }
}

extension SetUtils<E> on Set<E> {
  /*static Set<E> deepCopyValuesOnlyFrom(Set other) {
    final Set<E> result = {};
    for (final x in other) {
      if (x is Map) {
        result.add(MapUtils.deepCopyValuesOnlyFrom(x) as E);
      } else if (x is List) {
        result.add(ListUtils.deepCopyValuesOnlyFrom(x as List<E>) as E);
      } else if (x is Set<E>) {
        result.add(SetUtils.deepCopyValuesOnlyFrom(x as Set<E>) as E);
      } else {
        result.add(x as E);
      }
    }
    return result;
  }*/
}

extension StringNUtils on String? {
  bool get isNumeric => double.tryParse(this ?? '') != null;
  bool get isInt => int.tryParse(this ?? '') != null;
  int? get toInt => int.tryParse(this ?? '');
  double? get toDouble => double.tryParse(this ?? '');
}

extension StringUtils on String {
  String sentenceCase({bool addFullstop = false}) =>
      substring(0, 1).toUpperCase() +
      substring(1) +
      (addFullstop && !endsWith('.') ? '.' : '');

  String camelCase({bool removeSpace = false}) =>
      split(' ').map((e) => e.sentenceCase()).join(removeSpace ? '' : ' ');

  bool get isEmail => RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(this);

  bool get isPhoneNumber =>
      RegExp(r'\+?\d{1,4}?[-.\s]?\(?\d{1,3}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}').hasMatch(this);
      //RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(this);

  bool get isURL {
    final Uri? x = Uri.tryParse(this);
    return x != null && x.isAbsolute;
  }

  List<String> get words => split(' ').map<String>((e) => e.trim()).toList()
    ..removeWhere((element) => element.isEmpty);

  List<String> sentences({Pattern pattern = "."}) =>
      split(pattern).map<String>((e) => e.trim()).toList()
        ..removeWhere((x) => x.isEmpty);

  String get removeSymbols => replaceAll(RegExp(r'(?:_|[^\w\s])+'), '');

  /// Credit goes to https://pub.dev/packages/remove_emoji
  String removeEmoji({
    String emojiWord = '',
     bool trim = false,
  }) =>
      RemoveEmoji().removemoji(
        this,
        emojiWord,
        trim,
      );
}

extension DurationUtils on Duration {
  int get inWeeks => inDays ~/ 7;

  int get inMonths => inDays ~/ 30;

  int get inYears => inDays ~/ 365;

  String prettyStringCustom({
     bool year = false,
     bool month = false,
     bool week = false,
     bool day = false,
     bool hour = false,
     bool minute = false,
     bool second = false,
     bool millisecond = false,
     bool microsecond = false,
     String separator = " ",
     String unitSeparator = ", ",
     bool reverseOrder = false,
     CPair<String, String> yearText =
        const CPair<String, String>("Year", "Years"),
     CPair<String, String> monthText =
        const CPair<String, String>("Month", "Months"),
     CPair<String, String> weekText =
        const CPair<String, String>("Week", "Weeks"),
     CPair<String, String> dayText =
        const CPair<String, String>("Day", "Days"),
     CPair<String, String> hourText =
        const CPair<String, String>("Hour", "Hours"),
     CPair<String, String> minuteText =
        const CPair<String, String>("Minute", "Minutes"),
     CPair<String, String> secondText =
        const CPair<String, String>("Second", "Seconds"),
     CPair<String, String> millisecondText =
        const CPair<String, String>("Millisecond", "Milliseconds"),
     CPair<String, String> microsecondText =
        const CPair<String, String>("Microsecond", "Microseconds"),
  }) {
    String _getText(int n, CPair<String, String> texts) =>
        n == 1 ? texts.a : texts.b;

    Duration x = this;

    List<String> parts = [];

    if (year && x.inYears.abs() > 0) {
      final int n = x.inYears.abs();
      parts.add(n.toString() + separator + _getText(n, yearText));
      x -= Duration(days: n * 365);
    }
    if (month && x.inMonths.abs() > 0) {
      final int n = x.inMonths.abs();
      parts.add(n.toString() + separator + _getText(n, monthText));
      x -= Duration(days: n * 30);
    }
    if (week && x.inWeeks.abs() > 0) {
      final int n = x.inWeeks.abs();
      parts.add(n.toString() + separator + _getText(n, weekText));
      x -= Duration(days: n * 7);
    }
    if (day && x.inDays.abs() > 0) {
      final int n = x.inDays.abs();
      parts.add(n.toString() + separator + _getText(n, dayText));
      x -= Duration(days: n);
    }
    if (hour && x.inHours.abs() > 0) {
      final int n = x.inHours.abs();
      parts.add(n.toString() + separator + _getText(n, hourText));
      x -= Duration(hours: n);
    }
    if (minute && x.inMinutes.abs() > 0) {
      final int n = x.inMinutes.abs();
      parts.add(n.toString() + separator + _getText(n, minuteText));
      x -= Duration(minutes: n);
    }
    if (second && x.inSeconds.abs() > 0) {
      final int n = x.inSeconds.abs();
      parts.add(n.toString() + separator + _getText(n, secondText));
      x -= Duration(seconds: n);
    }
    if (millisecond && x.inMilliseconds.abs() > 0) {
      final int n = x.inMilliseconds.abs();
      parts.add(n.toString() + separator + _getText(n, millisecondText));
      x -= Duration(milliseconds: n);
    }
    if (microsecond && x.inMicroseconds.abs() > 0) {
      final int n = x.inMicroseconds.abs();
      parts.add(n.toString() + separator + _getText(n, microsecondText));
      x -= Duration(microseconds: n);
    }

    if (reverseOrder) {
      parts = List<String>.from(parts.reversed);
    }

    final String result = parts.join(unitSeparator);

    return result;
  }

  String prettyStringHighestOnly({
     bool year = true,
     bool month = true,
     bool week = true,
     bool day = true,
     bool hour = true,
     bool minute = true,
     bool second = true,
     bool millisecond = false,
     bool microsecond = false,
     String separator = " ",
     String noTimeLeft = "0 Seconds",
     CPair<String, String> yearText =
        const CPair<String, String>("Year", "Years"),
     CPair<String, String> monthText =
        const CPair<String, String>("Month", "Months"),
     CPair<String, String> weekText =
        const CPair<String, String>("Week", "Weeks"),
     CPair<String, String> dayText =
        const CPair<String, String>("Day", "Days"),
     CPair<String, String> hourText =
        const CPair<String, String>("Hour", "Hours"),
     CPair<String, String> minuteText =
        const CPair<String, String>("Minute", "Minutes"),
     CPair<String, String> secondText =
        const CPair<String, String>("Second", "Seconds"),
     CPair<String, String> millisecondText =
        const CPair<String, String>("Millisecond", "Milliseconds"),
     CPair<String, String> microsecondText =
        const CPair<String, String>("Microsecond", "Microseconds"),
  }) {
    if (inYears > 0 && year) {
      return prettyStringCustom(
        year: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inMonths > 0 && month) {
      return prettyStringCustom(
        month: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inWeeks > 0 && week) {
      return prettyStringCustom(
        week: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inDays > 0 && day) {
      return prettyStringCustom(
        day: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inHours > 0 && hour) {
      return prettyStringCustom(
        hour: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inMinutes > 0 && minute) {
      return prettyStringCustom(
        minute: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inSeconds > 0 && second) {
      return prettyStringCustom(
        second: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inMilliseconds > 0 && millisecond) {
      return prettyStringCustom(
        millisecond: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    } else if (inMicroseconds > 0 && microsecond) {
      return prettyStringCustom(
        microsecond: true,
        separator: separator,
        yearText: yearText,
        monthText: monthText,
        weekText: weekText,
        dayText: dayText,
        hourText: hourText,
        minuteText: minuteText,
        secondText: secondText,
        millisecondText: millisecondText,
        microsecondText: microsecondText,
      );
    }
    return noTimeLeft;
  }
}

extension DateTimeUtils on DateTime {
  bool isToday() {
    toString();
    final DateTime now = DateTime.now();
    final DateTime thisDate = toLocal();
    return thisDate.year == now.year &&
        thisDate.month == now.month &&
        thisDate.day == now.day;
  }

  Date toDate() => Date.fromDateTime(this);
}

extension BoolUtils on bool {
  int get toNumeric => this ? 1 : 0;
  String get toNumericString => toNumeric.toString();
}

extension ThemeModeUtils on ThemeMode {
  String prettyString() => toString().split('.').last.sentenceCase();
}

extension RandomUtils on Random {
  int randomInt({
    required int min,
    required int max,
  }) =>
      min + nextInt(max - min);

  double randomDouble({
    required double min,
    required double max,
  }) =>
      nextDouble() * (max - min) + min;
}

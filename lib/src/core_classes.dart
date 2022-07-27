library core_classes;

class Date {
  final int day;
  final int month;
  final int year;
  const Date({required this.year, this.month = 1, this.day = 1});

  factory Date.today() {
    final DateTime thisMoment = DateTime.now();
    return Date(
      year: thisMoment.year,
      month: thisMoment.month,
      day: thisMoment.day,
    );
  }

  factory Date.yesterday() => Date.today() - const Duration(days: 1);

  factory Date.tomorrow() => Date.today() + const Duration(days: 1);

  factory Date.fromDateTime(DateTime dateTime) =>
      Date(year: dateTime.year, month: dateTime.month, day: dateTime.day);

  factory Date.parse(String date) {
    /*RegExp dateTimeRegEx = 
      RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
          r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d+))?)?)?' // Time part.
          r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.*/

    if (RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)').firstMatch(date) == null) {
      throw FormatException("Invalid date format", date);
    }

    final List<String> x = date.split(' ').first.split('-');
    return Date(
      year: int.parse(x[0]),
      month: int.parse(x[1]),
      day: int.parse(x[2]),
    );
  }

  static Date? tryParse(String date) {
    late final Date res;
    try {
      res = Date.parse(date);
    } on FormatException {
      return null;
    }
    return res;
  }

  Date operator +(Duration o) => Date.fromDateTime(toDateTime().add(o));

  Date operator -(Duration o) => Date.fromDateTime(toDateTime().subtract(o));

  bool isToday() {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool wasYesterday() =>
      Date.fromDateTime(
        DateTime.now().subtract(
          const Duration(
            days: 1,
          ),
        ),
      ) ==
      this;

  bool isTomorrow() =>
      Date.fromDateTime(
        DateTime.now().add(
          const Duration(
            days: 1,
          ),
        ),
      ) ==
      this;

  @override
  bool operator ==(Object o) =>
      (o is Date && o.day == day && o.month == month && o.year == year) ||
      (o is DateTime && o.day == day && o.month == month && o.year == year);

  @override
  int get hashCode => int.parse(toString());

  @override
  String toString() => "$year-$month-$day";

  String toJson() => toString();

  DateTime toDateTime() => DateTime(
        year,
        month,
        day,
      );
}

class Time {

}

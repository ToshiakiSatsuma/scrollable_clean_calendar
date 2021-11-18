import 'package:scrollable_clean_calendar/utils/date_models.dart';

class WeekHelper {
  static List<Month> extractWeeks({
    required DateTime minDate, // カレンダーの開始日
    required DateTime maxDate, // カレンダーの終了日
    int startWeekDay = DateTime.monday, // 週始まりの曜日
  }) {
    // 週終わりの曜日を求める
    // HACK: intなので計算で求める
    int endWeekDay = startWeekDay + 6;
    if (endWeekDay > 7) {
      endWeekDay = endWeekDay - 7;
    }

    // カレンダーの最初の週の最初の日を求める
    DateTime weekMinDate = _startDayOfWeek(minDate, startWeekDay);

    // カレンダーの最後の週の最終の日を求める
    DateTime weekMaxDate = _endDayOfWeek(maxDate, endWeekDay);

    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = _endDayOfWeek(minDate, endWeekDay);

    if (!lastDayOfWeek.isBefore(weekMaxDate)) {
      return <Month>[
        Month(<Week>[Week(firstDayOfWeek, lastDayOfWeek)])
      ];
    } else {
      List<Month> months = [];
      List<Week> weeks = [];

      while (lastDayOfWeek.isBefore(weekMaxDate)) {
        Week week = Week(firstDayOfWeek, lastDayOfWeek);
        weeks.add(week);

        if (week.isLastWeekOfMonth) {
          if (lastDayOfWeek.isSameDayOrAfter(minDate)) {
            months.add(Month(weeks));
          }

          weeks = [];

          firstDayOfWeek = firstDayOfWeek.toFirstDayOfNextMonth();
          lastDayOfWeek = _endDayOfWeek(firstDayOfWeek, endWeekDay);

          weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
        }

        firstDayOfWeek = lastDayOfWeek.nextDay;
        lastDayOfWeek = _endDayOfWeek(firstDayOfWeek, endWeekDay);
      }

      if (!lastDayOfWeek.isBefore(weekMaxDate)) {
        weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
      }

      months.add(Month(weeks));

      months.removeWhere((element) => maxDate.isBefore(element.weeks.first.firstDay));

      return months;
    }
  }

  // 週の始まりの日付を求める
  static DateTime _startDayOfWeek(DateTime targetDate, int startWeekDay) {
    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (targetDate.weekday == startWeekDay) {
      return targetDate;
    } else {
      // dateの曜日とweekDayの差を求める
      int days = (startWeekDay - targetDate.weekday).abs();
      if (days > 4) {
        days = 7 - days;
      }

      return targetDate.subtract(Duration(days: days));
    }
  }

  // 週のおわりの日付を求める
  static DateTime _endDayOfWeek(DateTime targetDate, int endWeekDay) {
    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (targetDate.weekday == endWeekDay) {
      return targetDate;
    } else {
      // dateの曜日とweekDayの差を求める
      int days = (endWeekDay - targetDate.weekday).abs();
      if (days > 4) {
        days = 7 - days;
      }

      return targetDate.subtract(Duration(days: -days));
    }
  }

  static List<int> daysPerMonth(int year) => <int>[
        31,
        isLeapYear(year) ? 29 : 28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
      ];

  static bool isLeapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }
}

extension DateUtilsExtensions on DateTime {
  bool get isLeapYear {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }

  int get daysInMonth => WeekHelper.daysPerMonth(year)[month - 1];

  DateTime toFirstDayOfNextMonth() => DateTime(
        year,
        month + 1,
      );

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  DateTime removeTime() => DateTime(year, month, day);
}

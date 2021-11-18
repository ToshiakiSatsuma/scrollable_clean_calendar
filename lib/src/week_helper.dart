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
    DateTime currentDate = minDate;

    if (!minDate.isBefore(maxDate)) {
      return <Month>[];
    } else {
      List<Month> months = [];
      List<Week> weeks = [];

      List<DateTime> _datesInWeek = [];

      while (!currentDate.isAfter(maxDate)) {
        _datesInWeek.add(currentDate);

        if (currentDate.weekday == endWeekDay || currentDate.day == currentDate.daysInMonth) {
          Week week = Week(_datesInWeek[0], _datesInWeek[_datesInWeek.length - 1]);
          weeks.add(week);

          if (currentDate.day == currentDate.daysInMonth) {
            months.add(Month(weeks));
            weeks = [];
          }

          _datesInWeek = [];
        }

        currentDate = currentDate.add(Duration(days: 1));

      }

      return months;
    }
  }

  static List<int> daysPerMonth(int year) =>
      <int>[
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

  DateTime toFirstDayOfNextMonth() =>
      DateTime(
        year,
        month + 1,
      );

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  DateTime removeTime() => DateTime(year, month, day);
}

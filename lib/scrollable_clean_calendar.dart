library scrollable_clean_calendar;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/resources.dart';
import 'package:scrollable_clean_calendar/src/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/src/week_helper.dart';
import 'package:scrollable_clean_calendar/utils/date_models.dart';

import 'src/week_helper.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

typedef RangeDate = Function(DateTime minDate, DateTime? maxDate);
typedef SelectDate = Function(DateTime date);
typedef TextStyleFunction = Function(bool isSelected);

// HACK: 日曜始まりで固定
class ScrollableCleanCalendar extends StatefulWidget {
  ScrollableCleanCalendar({
    this.locale = 'ja',
    required this.minDate,
    required this.maxDate,
    this.isRangeMode = true,
    this.onRangeSelected,
    this.showDaysWeeks = true,
    this.monthLabelStyle,
    this.monthLabelAlign = MainAxisAlignment.center,
    this.dayLabelStyle,
    this.dayWeekLabelStyle,
    this.selectedDateColor = Colors.indigo,
    this.rangeSelectedDateColor = Colors.blue,
    this.selectedDateTextColor = Colors.white,
    this.holidayTextColor = Colors.grey,
    this.weekdayTextColor = Colors.black,
    this.selectDateRadius = 15,
    this.onTapDate,
    this.renderPostAndPreviousMonthDates = false,
    this.disabledDateColor = Colors.grey,
    this.startWeekDay = DateTime.sunday,
    this.initialDateSelected,
    this.endDateSelected,
    this.scrollController,
  });

  final ScrollController? scrollController;
  final bool isRangeMode;
  final String locale;
  final bool showDaysWeeks;
  final bool renderPostAndPreviousMonthDates;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? initialDateSelected;
  final DateTime? endDateSelected;

  final int startWeekDay;

  final double selectDateRadius;

  final RangeDate? onRangeSelected;
  final TextStyleFunction? dayLabelStyle;
  final SelectDate? onTapDate;

  ///Styles
  final TextStyle? monthLabelStyle;
  final TextStyle? dayWeekLabelStyle;
  final Color selectedDateColor;
  final Color rangeSelectedDateColor;
  final Color selectedDateTextColor;
  final Color holidayTextColor;
  final Color weekdayTextColor;
  final Color disabledDateColor;
  final MainAxisAlignment monthLabelAlign;

  @override
  _ScrollableCleanCalendarState createState() => _ScrollableCleanCalendarState();
}

class _ScrollableCleanCalendarState extends State<ScrollableCleanCalendar> {
  CleanCalendarController? _cleanCalendarController;

  List<Month>? months;
  DateTime? rangeMinDate;
  DateTime? rangeMaxDate;
  DateTime? _minDate;
  DateTime? _maxDate;

  @override
  void initState() {
    initializeDateFormatting();

    final _minDateDay = widget.renderPostAndPreviousMonthDates ? 1 : widget.minDate.day;
    final _maxDateDay = widget.renderPostAndPreviousMonthDates
        ? WeekHelper.daysPerMonth(widget.maxDate.year)[widget.maxDate.month - 1]
        : widget.maxDate.day;

    _minDate = DateTime(widget.minDate.year, widget.minDate.month, _minDateDay);
    _maxDate = DateTime(widget.maxDate.year, widget.maxDate.month, _maxDateDay, 23, 59, 00);
    months = WeekHelper.extractWeeks(
      minDate: _minDate!,
      maxDate: _maxDate!,
      startWeekDay: widget.startWeekDay,
    );

    _cleanCalendarController = CleanCalendarController(startWeekDay: widget.startWeekDay);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.initialDateSelected != null &&
          (widget.initialDateSelected!.isAfter(widget.minDate) ||
              widget.initialDateSelected!.isSameDay(widget.minDate))) {
        _onDayClick(widget.initialDateSelected!);
      }

      if (widget.endDateSelected != null &&
          (widget.endDateSelected!.isBefore(widget.maxDate) || widget.endDateSelected!.isSameDay(widget.maxDate))) {
        _onDayClick(widget.endDateSelected!);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Table(
            children: [
              // 週ラベル
              _buildDayWeeksRow(context),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            cacheExtent: (MediaQuery.of(context).size.width / DateTime.daysPerWeek) * 6,
            itemCount: months!.length,
            itemBuilder: (context, index) {
              final month = months![index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          // 年月ラベル
                          _buildMonthLabelRow(month, context),
                          SizedBox(height: 20),
                          // 日付
                          Table(
                            key: ValueKey('Calendar$index'),
                            children: [
                              ...month.weeks.map(
                                (Week week) {
                                  DateTime firstDay = week.firstDay;

                                  // 日ラベル
                                  return _buildDaysRow(week, firstDay, context);
                                },
                              ).toList(growable: false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildMonthLabelRow(Month month, BuildContext context) {
    return Row(
      mainAxisAlignment: widget.monthLabelAlign,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            '${DateFormat('yyyy年MM月', widget.locale).format(DateTime(month.year, month.month))}',
            style: widget.monthLabelStyle ??
                Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.grey[800],
                    ),
          ),
        ),
      ],
    );
  }

  TableRow _buildDaysRow(Week week, DateTime firstDay, BuildContext context) {
    // _cleanCalendarController.dayOfWeek()
    // weekの日数を生成
    int dayCount = week.duration + 1;

    List<Widget> listContent = <Widget>[
      // 月初日が含まれている場合
      if (week.firstDay.day == 1)
        ...List.generate(DateTime.daysPerWeek - dayCount, (_) {
          return SizedBox.shrink();
        }),

      ...List.generate(dayCount, (int position) {
        DateTime day = DateTime(week.firstDay.year, week.firstDay.month, firstDay.day + position);

        bool rangeFeatureEnabled = rangeMinDate != null;

        bool isSelected = false;
        bool isSandwiched = false;

        if (rangeFeatureEnabled) {
          if (rangeMinDate != null && rangeMaxDate != null) {
            if (day.isAtSameMomentAs(rangeMinDate!) || day.isAtSameMomentAs(rangeMaxDate!)) {
              isSelected = true;
            } else if (day.isSameDayOrAfter(rangeMinDate!) && day.isSameDayOrBefore(rangeMaxDate!)) {
              isSandwiched = true;
            }
          } else {
            isSelected = day.isAtSameMomentAs(rangeMinDate!);
          }
        }

        return TableCell(
          key: ValueKey(DateFormat('dd-MM-yyyy', widget.locale).format(day)),
          child: GestureDetector(
            onTap: () {
              _onDayClick(day);
            },
            child: Container(
              key: ValueKey('${DateFormat('dd-MM-yyyy', widget.locale).format(day)}_container'),
              decoration: BoxDecoration(
                color: _getBackgroundColor(isSelected, isSandwiched, day),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Text(
                    DateFormat('d').format(day),
                    style: widget.dayLabelStyle != null
                        ? widget.dayLabelStyle!(isSelected)
                        : Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday)
                                      ? holidayTextColor
                                      : weekdayTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),

      // 月末日が含まれている場合
      if (week.isLastWeekOfMonth)
        ...List.generate(DateTime.daysPerWeek - dayCount, (_) {
          return SizedBox.shrink();
        }),
    ];

    return TableRow(children: listContent);
  }

  Color _getBackgroundColor(bool isSelected, bool isSandwiched, DateTime day) {
    if (isSelected) {
      return widget.selectedDateColor;
    } else if (isSandwiched) {
      return widget.rangeSelectedDateColor;
    }
    return Colors.transparent;
  }

  TableRow _buildDayWeeksRow(BuildContext context) {
    return widget.showDaysWeeks
        ? TableRow(
            children: [
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                TableCell(
                  child: Container(
                    height: 32,
                    child: Center(
                      child: Text(
                        _cleanCalendarController!
                            .getDaysOfWeek(widget.locale)[((widget.startWeekDay + i) % 7)]
                            .capitalize(),
                        key: ValueKey("WeekLabel$i"),
                        style: widget.dayWeekLabelStyle ??
                            Theme.of(context).textTheme.bodyText1!.copyWith(
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : TableRow(
            children: [
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                TableCell(
                  child: SizedBox.shrink(),
                ),
            ],
          );
  }

  void _onDayClick(DateTime date) {
    if (widget.isRangeMode) {
      if (rangeMinDate == null || rangeMaxDate != null) {
        rangeMinDate = date;
        rangeMaxDate = null;
      } else if (date.isBefore(rangeMinDate!)) {
        rangeMaxDate = rangeMinDate;
        rangeMinDate = date;
      } else if (date.isAfter(rangeMinDate!) || date.isSameDay(rangeMinDate!)) {
        rangeMaxDate = date;
      }
    } else {
      rangeMinDate = date;
      rangeMaxDate = date;
    }
    setState(() {});

    if (widget.onTapDate != null) {
      widget.onTapDate!(date);
    }

    if (widget.onRangeSelected != null) {
      widget.onRangeSelected!(rangeMinDate!, rangeMaxDate);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'スクロールできるカレンダーのテスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('カレンダーリスト表示'),
        ),
        body: ScrollableCleanCalendar(
          onRangeSelected: (firstDate, secondDate) {
            print('開始日: $firstDate');
            print('終了日: $secondDate');
          },
          onTapDate: (date) {
            print('タップ: $date');
          },
          minDate: DateTime.now(),
          maxDate: DateTime.now().add(
            Duration(days: 365),
          ),
          monthLabelAlign: MainAxisAlignment.start,
          showDaysWeeks: true,
          renderPostAndPreviousMonthDates: true,
        ),
      ),
    );
  }
}

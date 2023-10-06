import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/login_view.dart';


class CalendarWidget extends StatelessWidget {
  // final String serverMsg;
  // final bool error;
  // CalendarWidget({
  //   required this.serverMsg,
  //   required this.error,
  // });

  Rx<DateTime> selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;

  Rx<DateTime> focusedDay = DateTime.now().obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() => TableCalendar(
      focusedDay: focusedDay.value,
      firstDay: DateTime(2022,10,1),
      lastDay: DateTime(2030,10,31),
      locale: 'ko-KR',
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        // tableBorder: TableBorder(
        //   bottom: BorderSide(color: Color.fromARGB(255, 204, 204, 204)),
        // ),
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: Color.fromARGB(255, 18, 136, 248),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        selectedDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
      )),
      onDaySelected: ( selectedDay, focusedDay) {
        this.selectedDay = selectedDay.obs;
        this.focusedDay = focusedDay.obs;
        print('바뀜');

      },
      selectedDayPredicate: (day) {
        // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
        return isSameDay(selectedDay.value, day);
      },
      onFormatChanged: (format){
        if(_calendarFormat != format){
          _calendarFormat = format.obs;
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        focusedDay = focusedDay;
      },
    ));
  }
}
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/report_controller.dart';

import '../../models/calender_report/calender_report_model.dart';

/// Example event class.
class Event {
  final String title;
  final String date;
  final String inTime;
  final String outTime;

  const Event(this.title, this.date, this.inTime, this.outTime);

  @override
  String toString() => title;
}

class CalendarController extends GetxController {
  AttendanceController attendanceController;
  final isLoading = true.obs;
  final focusDate = DateTime.now().obs;
  Rx<ValueNotifier<List<Event>>> selectedEvents =
      ValueNotifier<List<Event>>([]).obs;

  List strings = [
    {"day": "2022-08-01", "status": "P"},
    {"day": "2022-08-02", "status": "A"},
    {"day": "2022-08-03", "status": "A"}
  ];

  final kEvents = LinkedHashMap<DateTime, List<Event>>().obs;

  CalendarController(this.attendanceController);

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  /// Returns a list of [DateTime] objects from [first] to [last], inclusive.
  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  @override
  void onInit() {
    kFirstDay.value = DateTime(kToday.year, kToday.month - 6, 1);
    kLastDay.value = DateTime(kToday.year, kToday.month + 6, 30);
    setEvents(attendanceController);
    super.onInit();
  }

  uiUpdate() {
    update();
  }

  final kToday = DateTime.now();
  final kFirstDay = DateTime.now().obs;
  final kLastDay = DateTime.now().obs;

  List<Event> _getEventsForDays(Iterable<DateTime> days) {

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> ev = [];
    try {
      kEvents.value.forEach((key, value) {
        if (key.day.compareTo(day.day) == 0 &&
            key.month.compareTo(day.month) == 0 &&
            key.year.compareTo(day.year) == 0) {
          ev.add(value.first);
        }
      });

  //    ev.add(Event("day,C", "", "", ""));
//print("ev  ${ev}");
      return ev;
    } catch (ex) {
      print(ex);
      return [Event("day,C", day.toIso8601String(), "", "")];
    } finally {
      uiUpdate();
    }
  }

  setEvents(AttendanceController controller,
      {String date, int empId = 1, DateTime focusDate}) async {
    try {
      isLoading.value = true;
      ReportController dbHelper = Get.put(ReportController(false));

      print("reportController :: ${empId.toString()}");
      print(
          "reportController emp  :: ${dbHelper.selectedEmployee.value.index}");

      //  empId = dbHelper.selectedEmployee.value.index;
      String fDate, tDate;

      if (date == null && empId == 1) {
        fDate =
            "${DateTime.now().year.toString()}-${DateTime.now().month.toString()}";

        tDate =
            "${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2, "0")}-31";
          print("if data");
       await dbHelper.viewCalenderReport2(empId.toString(), fDate);
      }
      else if (empId == 1) {
        empId = dbHelper.selectedEmployee.value.index;
        fDate = "$date";
        tDate = "$date-31";
        print("elseif data");
         await dbHelper.viewCalenderReport(empId.toString(), fDate);

      }

      else {
        empId = dbHelper.selectedEmployee.value.index;
        fDate =
            "${focusDate.year}-${focusDate.month.toString().padLeft(2, "0")}";
        tDate =
            "${focusDate.year}-${focusDate.month.toString().padLeft(2, "0")}-31";
         print("else data" );
          await dbHelper.viewCalenderReport(empId.toString(), fDate);
      }

      List<Attendance> newList =
          dbHelper.calenderEmployeeModle.value.data.attendance;

      // dbHelper.calenderEmployeeModle.value.data.attendance.forEach((element) {
      //   DateTime fromDateTime, toDateTime, elementDate;
      //   fromDateTime = DateTimeFormatter.displayYYYYMMDD.parse(element.finalFirstInTime);
      //   toDateTime = DateTimeFormatter.displayYYYYMMDD.parse(tDate);
      //   elementDate = DateTimeFormatter.displayYYYYMMDD.parse(element.date);
      //   if (elementDate.isBetween(fromDateTime, toDateTime)) {
      //     newList.add(element);
      //   }
      // });

      //  newList.sort((a, b) => a['e'] != null && b.empId != null ? a.empId.compareTo(b.empId) : 1);

      strings = convertDataToCalendarData(
        newList,
      );
      print("string ::${jsonEncode(strings)}");

      var _kEventSource;

      if (strings.length > 1) {
        _kEventSource = Map.fromIterable(strings,
            key: (item) => DateTime.utc(
                int.parse(item['day'].toString().split("-").first),
                int.parse(item['day'].toString().split("-")[1]),
                int.parse(item['day'].toString().split("-").last)),
            value: (item) => List.generate(
                1,
                (index) => Event("${item['day']},${item['status']}",
                    item['day'], item['inTime'], item['outTime'])));
        kEvents.value = LinkedHashMap<DateTime, List<Event>>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_kEventSource);
      } else if (strings.length == 1) {
        List<Event> events = [];
        events.add(Event(
            "${strings.first['day']},${strings.first['status']}",
            strings.first['day'],
            strings.first['inTime'],
            strings.first['outTime']));
        _kEventSource = Map<DateTime, List<Event>>();
        _kEventSource[DateTime.utc(
                int.parse(strings.first['day'].toString().split("-").first),
                int.parse(strings.first['day'].toString().split("-")[1]),
                int.parse(strings.first['day'].toString().split("-").last))] =
            events;
        kEvents.value = LinkedHashMap<DateTime, List<Event>>(
          hashCode: getHashCode,
        )..addAll(_kEventSource);
        print("events=${kEvents.toString()}");
      } else {
        kEvents.value = [] as LinkedHashMap<DateTime, List<Event>>;
      }

      selectedEvents.value = ValueNotifier(_getEventsForDays(List.generate(
          1, (i) => DateTime(kToday.year, kToday.month, kToday.day))));

      print("year ::${kToday.year}");
      print("month ::${kToday.month}");
      print("day ::${kToday.day}");
      print("selected events :: ${ValueNotifier(_getEventsForDays(List.generate(
          1, (i) => DateTime(kToday.year, kToday.month, kToday.day))))}");
      isLoading.value = false;

    } catch (ex) {
      print("events LoaderError=${kEvents.toString()}");
    }

  }

  List convertDataToCalendarData(List<Attendance> entries, {int empId = 12}) {
    try {
      List mapRecords = [];
      entries.forEach((element) {
        mapRecords.add({
          "day": element.date,
          "status": element.attendanceStatus,
          "inTime": element.finalFirstInTime != null
              ? DateFormat("HH:mm").format(DateTimeFormatter.serverSendDate
                  .parse(element.finalFirstInTime))
              : "NA",
          "outTime": element.finalLastOutTime != null
              ? DateFormat("HH:mm").format(DateTimeFormatter.serverSendDate
                  .parse(element.finalLastOutTime))
              : "NA"
        });
      });

      return mapRecords;
    } catch (ex) {
      return [];
    }
  }

  // getStatus(String element, String element2) {
  //   try {
  //     String difference = getTimeDifferenceString(element, element2);
  //     print("Time Difference $difference");
  //     if (difference != "_") {
  //       DateTime dateTime = DateFormat("HH:mm").parse(difference);
  //       TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  //       int hours = timeOfDay.hour;
  //       if (hours >= 7.45) {
  //         return "P";
  //       } else if (hours > 3.45 || hours < 7.45) {
  //         return "H";
  //       } else {
  //         return "A";
  //       }
  //     }
  //   } catch (ex) {}
  // }

  String getTimeDifferenceString(String inTime, String outTime) {
    DateFormat _format = DateFormat("HH:mm:ss");
    int timeDifference;
    DateTime dtOutTime, dtInTime;
    try {
      log("inTime=$inTime,outTime=$outTime");
      int hours, minutes;

      if (outTime != null || inTime != null) {
        if (outTime != null)
          dtOutTime = _format.parse(outTime);
        else
          return "_";

        if (inTime != null)
          dtInTime = _format.parse(inTime);
        else
          return "_";

        timeDifference = dtOutTime.difference(dtInTime).inMinutes;
        hours = timeDifference ~/ 60;
        minutes = (timeDifference) % 60;
        log("hours=$hours:minutes=$minutes");

        return "${hours < 10 ? "0${hours.isEqual(0) ? '0' : hours}" : hours}:${minutes < 10 ? "0${minutes.isEqual(0) ? '0' : minutes}" : minutes}";
      } else {
        return "00:00";
      }
    } catch (ex) {
      return ex.toString();
    }
  }
}

/// Example event class.
// class Event  extends GetxController{
//   final kToday =   DateTime.now();
//   List strings = [
//     {
//       "day": "2022-05-01",
//       "status": "P"
//     },
//     {
//       "day": "2022-05-02",
//       "status": "A"
//     },
//     {
//       "day": "2022-05-03",
//       "status": "A"
//     }
//   ];
//   final String title;
//   final kEvents = LinkedHashMap<DateTime, List<Event>>().obs;
//   final kEventSource = Map().obs;
//   final kFirstDay=DateTime.now().obs;
//   final kLastDay=DateTime.now().obs;
//
//   @override
//   void onInit() {
//     kFirstDay.value = DateTime(kToday.year, kToday.month-1, 1);
//     kLastDay.value = DateTime(kToday.year, kToday.month+12,30);
//     setEvents();
//     super.onInit();
//
//   } // ..addAll(_kEventSource);
//
//
//   Event(this.title);
//
//   @override
//   String toString() => title;
//
//
//
//
//   /// Example events.
//   ///
//   /// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
//   ///
//   ///

//
//
//
//
//   int getHashCode(DateTime key) {
//     return key.day * 1000000 + key.month * 10000 + key.year;
//   }
//
//   /// Returns a list of [DateTime] objects from [first] to [last], inclusive.
//   List<DateTime> daysInRange(DateTime first, DateTime last) {
//     final dayCount = last.difference(first).inDays + 1;
//     return List.generate(
//       dayCount,
//           (index) => DateTime.utc(first.year, first.month, first.day + index),
//     );
//   }
//
//
//
//
// }

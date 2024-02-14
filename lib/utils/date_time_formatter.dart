import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormatter {
  static final DateFormat displayDateWithDay = DateFormat('EEE, MMM d');
  static final DateFormat displayDay = DateFormat('c');
  static final DateFormat displayDDMMYYHHMMSS =
      DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat displayDDMMYY = DateFormat('dd-MM-yyyy');
  static final DateFormat displayYYYYMMDD = DateFormat('yyyy-MM-dd');
  static final DateFormat displayTime = DateFormat('HH:mm');
  static final DateFormat displayShortDate = DateFormat('dd, MMM');
  static final DateFormat displayDate = DateFormat('dd, MMM yyyy');
  static final DateFormat serverSendDate = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat serverTimestamp = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
  static final DateFormat uploadFileName = DateFormat('dd-MM-yyyy HH:mm:ss');
}

class ReturnDates {
  ///return in 13:00 format
  static String returnTime(DateTime dt) {
    final DateFormat formatter = DateFormat('HH:mm');
    String time = formatter.format(dt);
    return time;
  }

  ///return in 12:08 PM format
  static String returnTime12(DateTime dt) {
    final DateFormat formatter = DateFormat('hh.mm aa');
    String time = formatter.format(dt);
    return time;
  }

  ///return in Thu, Feb 18 format
  static String returnDate(DateTime dt) {
    final DateFormat formatter = DateFormat('EEE, MMM d');
    String date = formatter.format(dt);
    return date;
  }

  static String returnDateOne(DateTime dt) {
    final DateFormat formatter = DateFormat('dd, MMM yyyy');
    String date = formatter.format(dt);
    return date;
  }

  ///return day (Thu, Feb 18, will return 18)
  static String standaloneDay(DateTime dt) {
    final DateFormat formatter = DateFormat('c');
    String date = formatter.format(dt);
    return date;
  }

  static String durationToDisplayString(Duration duration) {
    String twoDigits(int n, {bool isHour = false}) =>
        n.toString().padLeft(2, isHour ? "" : "0");

    final List<String> tokens = [];
    String t = " min";

    if (duration.inMinutes > 60) {
      tokens.add(twoDigits(duration.inHours, isHour: true));
      t = " hr";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    tokens.add(twoDigitMinutes);

    return tokens.join(':') + t;
  }

  static String formatDiff(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, '0');
  }
}

class DateTimePicker {
  static Future<DateTime> selectDate(
      BuildContext context, DateTime firstDate, DateTime initialDate,
      {DateTime lastDate}) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate ?? DateTime(2101));

    if (picked != null) {
      return picked;
    } else {
      return DateTime.now();
    }
  }

  static Future<TimeOfDay> selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay pickedS = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (pickedS != null) {
      return pickedS;
    } else {
      return TimeOfDay.now();
    }
  }
}

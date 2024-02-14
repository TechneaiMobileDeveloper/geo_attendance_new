import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DatePickerController extends GetxController {
  final fromDateString = TextEditingController(
          text: DateFormat("yyyy-MM-dd").format(DateTime.now()))
      .obs;
  final toDateString = TextEditingController(
          text: DateFormat("yyyy-MM-dd").format(DateTime.now())).obs;



  // final fromDateString = TextEditingController(
  //     text: DateFormat("dd-MM-yyyy").format(DateTime.now()))
  //     .obs;
  // final toDateString = TextEditingController(
  //     text: DateFormat("dd-MM-yyyy").format(DateTime.now()))
  //     .obs;
}

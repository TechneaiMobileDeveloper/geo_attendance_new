import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/ui/widgets/custom_drop_down.dart';
import 'package:geo_attendance_system/ui/widgets/utils.dart';
import 'package:geo_attendance_system/utils/ui_helper.dart';
import 'package:get/get.dart';
import 'package:search_choices/search_choices.dart';
import '../../controllers/attendance_controller.dart';
import '../../res/app_colors.dart';
import '../../res/strings.dart';
import '../../utils/sizes.dart';
import '../../utils/text_styles.dart';
import '../../utils/widget/custom_appbar.dart';
import '../widgets/calendar_widget.dart';

class AttendanceReport extends StatelessWidget {
  final AttendanceController attendanceController =
      Get.find<AttendanceController>();
  final ReportController reportController = Get.find<ReportController>();

  AttendanceReport({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CalendarController controller =
        Get.put(CalendarController(attendanceController));
    // attendanceController.viewCalenderReport();
    //reportController.viewCalenderReport();
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          isHamburger: false,
          title: Strings.attendance,
          isBack: true,
          textStyle: TextStyles.appBarBold.copyWith(color: AppColors.white),
          color: AppColors.greyText,
        ),
        body: ReportBody(
            this.attendanceController, this.reportController, controller),
      ),
    );
  }
}

class ReportBody extends StatelessWidget {
  final AttendanceController attendanceController;
  final ReportController reportController;
  final CalendarController controller;

  final calenderDropdownValue = "".obs;

  ReportBody(this.attendanceController, this.reportController, this.controller,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Obx(
          () => reportController.dropDownEmployeeList.length > 0
              ? Container(
                  width: Get.width,
                  margin: EdgeInsets.symmetric(
                      vertical: Sizes.s15, horizontal: Sizes.s15),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: Sizes.s1, color: AppColors.primary),
                      borderRadius:
                          BorderRadius.all(Radius.circular(Sizes.s15))),
                  child: SearchChoices.single(
                    items: reportController.dropDownEmployeeList,
                    value: reportController.selectedEmployee.value,
                    searchHint: "Select one",
                    hint: 'Select Employee',
                    underline: Container(),
                    onChanged: (DropDownModal value) {
                      if (kDebugMode) {
                        print(value.toString());
                      }
                      print("dropDown Valuecccccccccccccc : $value");
                      reportController.selectedEmployee.value = value;
                      print("dropDown Value : $value");
                      print("dropDown Value : ${value.index}");
                      calenderDropdownValue.value = value.index.toString();
                      print(
                          "dropDown Value calenderDropdownValue : ${calenderDropdownValue.value}");
                      controller.setEvents(attendanceController,
                          empId: value.index,
                          focusDate: controller.focusDate.value);
                    },
                    // closeButton: TextButton(
                    //   onPressed: () {
                    //    // Navigator.pop();
                    //        // MyApp.navKey.currentState?.overlay?.context ?? context);
                    //   },
                    //   child: const Text(
                    //     "Close",
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                    // menuBackgroundColor: Colors.white,
                    // iconEnabledColor: Colors.pink,
                    // iconDisabledColor: Colors.grey,
                    // dialogBox: true,
                    isExpanded: true,
                  ),
                )
              : Container(),
        ),

        // Obx(
        //       () => reportController.dropDownEmployeeList.length > 0
        //       ? Container(
        //     width: Get.width,
        //     decoration: BoxDecoration(
        //         border:
        //         Border.all(width: Sizes.s1, color: AppColors.primary),
        //         borderRadius:
        //         BorderRadius.all(Radius.circular(Sizes.s15))),
        //     child: SearchChoices.single(
        //       //  label: reportController.selectedEmployee.value,
        //       items: reportController.dropDownEmployeeList,
        //       value: reportController.selectedEmployee.value,
        //       searchHint: "Select one",
        //       hint: 'Select Employee',
        //       underline: Container(),
        //       onChanged: (DropDownModal value) {
        //         if (kDebugMode) {
        //           print(value.toString());
        //         }
        //         reportController.selectedEmployee.value = value;
        //         print("dropDown Value : $value");
        //         print("dropDown Value : ${value.index}");
        //         calenderDropdownValue.value = value.index.toString();
        //         print(
        //             "dropDown Value calenderDropdownValue : ${calenderDropdownValue.value}");
        //         controller.setEvents(attendanceController,
        //             empId: value.index,
        //             focusDate: controller.focusDate.value);
        //       },
        //       dialogBox: true,
        //       isExpanded: true,
        //     ),
        //   )
        //       : Container(),
        // ),
        C10(),
        Obx(
          () => calenderDropdownValue.value == ""
              ? Container(
                  child: Center(
                    child: Text(" First Select Employee Name "),
                  ),
                )
              : TableComplexExample(attendanceController, "", (DateTime value) {
                  controller.focusDate.value = value;
                }),
        ),
        // Obx(() {
        //
        //   print("hii value :: ${calenderDropdownValue.value}");
        //   if (calenderDropdownValue.value == null)
        //     TableComplexExample(attendanceController, "", (DateTime value) {
        //       controller.focusDate.value = value;
        //     });
        //   else
        //     Container(
        //       child: Text("select DropDown value :: ${calenderDropdownValue.toString()}"),
        //     );
        // }
        //
        // ),
      ],
    );
  }
}

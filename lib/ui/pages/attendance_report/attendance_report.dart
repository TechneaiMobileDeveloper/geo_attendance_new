import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/date_picker_controller.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/models/attendances_report/attendances_report_model.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/style/style.dart';
import 'package:geo_attendance_system/ui/widgets/custom_date_widget.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class AttendanceReport extends StatelessWidget {
  final userType;
  final reportController = Get.find<ReportController>();
  final datePickerController = Get.put(DatePickerController());
  final bool isTodayApproved;

//  final int type;

  AttendanceReport({
    Key key,
    this.userType = false,
    this.isTodayApproved = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isTodayApproved)
      reportController.getAllEmployeeAttendanceData(isMultipleUser: userType);
    // reportController.employeeModelListReport();

    return SafeArea(
        child: Scaffold(
            appBar: CustomAppBar(
                isHamburger: false,
                color: AppColors.greyText,
                textStyle: TextStyles.appBarTittle,
                title: Strings.attendanceReport),
            floatingActionButton: Obx(
                () => reportController.empAttendancesReportData.value == null
                    ? Container()
                    : reportController.empAttendancesReportData.value.data !=
                                null ||
                            reportController
                                    .empAttendancesReportData.value.data ==
                                null
                        ? FloatingActionButton(
                            onPressed: () {
                              reportController.generateExampleDocument(
                                  reportController
                                      .empAttendancesReportData.value,
                                  Strings.attendanceReport);
                            },
                            child: Icon(Icons.download, color: AppColors.white),
                          )
                        : Container()
                //: Container(),
                ),
            body: GetX<ReportController>(
                initState: (s) => reportController.getAllEmployeeAttendanceData(
                    isNotApproved: false, isMultipleUser: userType),
                builder: (r) => r.empAttendancesReportData.value != null
                    ? reportController.empAttendancesReportData.value.data !=
                            null
                        ? widgetAcceptance(userType)
                        : loader()
                    : noDataFound(message: Strings.somethingWentWrong))));
  }

  widgetAcceptance(bool isMultiuser) {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        if (!isMultiuser) C25(),

        filterWidget(),
        C20(),
        if (!isMultiuser)
          Container(
            margin: EdgeInsets.symmetric(horizontal: Sizes.s10),
            child: AppTextField(
              isBoarder: false,
              decoration: InputDecoration(
                hintText: "Search user",
                counterText: '',
                counter: null,
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 32.0),
                    borderRadius: BorderRadius.circular(Sizes.s18)),
                contentPadding: EdgeInsets.symmetric(
                    vertical: Sizes.s12, horizontal: Sizes.s10),
                hintStyle:
                    TextStyles.defaultRegular.copyWith(fontSize: FontSizes.s15),
              ),
              inputFormatters: <TextInputFormatter>[
                // FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                LengthLimitingTextInputFormatter(35),
              ],
              keyboardType: TextInputType.text,
              onTextChanged: (val) {
                reportController.allEmployeeFilterReport(val,
                    fromDate: datePickerController.fromDateString,
                    toDate: datePickerController.toDateString);
                //initMethods(text: val);
              },
              suffixIcon: Icon(Icons.search, color: AppColors.black),
            ),
          ),

        C40(),
        if (!isMultiuser)
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [listHeader(), C10(), listBody()])
        // :
        //                 loader()
        // ),
      ],
    );
  }

  listBody() {
    return GroupedListView<Data, String>(
      shrinkWrap: true,
      elements: isTodayApproved
          ? reportController.todayApprovedemp.value.data
          // : type == Constants.AttendanceTypeIn
          //? reportController.empAttendancesReportData.value.data
          : reportController.empAttendancesReportData.value.data,
      sort: true,
      groupBy: (element) => element.date,
      groupSeparatorBuilder: (String groupByValue) => Padding(
        padding:
            EdgeInsets.only(left: Sizes.s15, right: Sizes.s15, top: Sizes.s10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: groupByValue,
              textAlign: TextAlign.start,
              fontSize: FontSizes.s13,
              fontWight: FontWeight.bold,
            ),
            Divider(
              thickness: 0.5,
              height: Sizes.s25,
            )
          ],
        ),
      ),
      indexedItemBuilder: (context, Data element, int index) =>
          customRowApproval(element, index),
      //  itemComparator: (item1, item2) => item1.date.compareTo(item2.date),
      // optional
      useStickyGroupSeparators: true,
      // optional
      floatingHeader: true,
      // optional
      order: GroupedListOrder.ASC, // optional
    );
  }

  listHeader() {
    return Container(
        padding: EdgeInsets.all(Sizes.s8),
        margin: EdgeInsets.symmetric(horizontal: Sizes.s8),
        color: AppColors.fontGray,
        child: Row(
          children: [
            Visibility(
              visible: true,
              child: Expanded(
                  flex: 1,
                  child: Text(
                    "Sr No",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal),
                  )),
            ),
            Expanded(
                flex: 2,
                child: Text("Emp ID",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Visibility(
              visible: true,
              child: Expanded(
                  flex: 2,
                  child: Text("Type",
                      textAlign: TextAlign.center,
                      style: TextStyles.textStyle
                          .copyWith(fontWeight: FontWeight.normal))),
            ),
            Expanded(
                flex: 2,
                child: Text("Name",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("InTime",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("OutTime",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("WHours",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Visibility(
              visible: false,
              child: Expanded(
                  child: Text("Action",
                      textAlign: TextAlign.center,
                      style: TextStyles.textStyle
                          .copyWith(fontWeight: FontWeight.normal))),
            )
          ],
        ));
  }

  widgetTitle(String title) {
    return Text(title, style: TextStyle(fontSize: FontSizes.s13));
  }

  String type = "Auto";

  customRowApproval(Data data, int index) {
    return Container(
        padding: EdgeInsets.all(Sizes.s2),
        child: Row(
          children: [
            Visibility(
              visible: true,
              child: Expanded(
                  flex: 1,
                  child: Text((index + 1).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyles.textStyle
                          .copyWith(fontWeight: FontWeight.normal))),
            ),
            Visibility(
              visible: false,
              child: Expanded(
                  flex: 2,
                  child: Text(data.date ?? Strings.empty,
                      textAlign: TextAlign.center,
                      style: TextStyles.textStyle
                          .copyWith(fontWeight: FontWeight.normal))),
            ),
            Expanded(
                flex: 2,
                child: Text(data.empId.toString() ?? 0,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text(
                    data.inType.toString() == "0"
                        ?  "${Strings.manual}"
                        : data.inType.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text(data.empName ?? Strings.empty,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data.inTime ?? Strings.empty,
                        textAlign: TextAlign.center,
                        style: TextStyles.textStyle
                            .copyWith(fontWeight: FontWeight.normal)),
                     getInTimeLocationWidget(data.inLocation,index),
                  ],
                )),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data.outTime ?? Strings.notPunchedOut,
                        textAlign: TextAlign.center,
                        style: TextStyles.textStyle
                            .copyWith(fontWeight: FontWeight.normal)),
                    getOutTimeLocationWidget(data.outLocation,index)
                  ],
                )),
            Expanded(
                flex: 2,
                child: Text(
                    reportController.getWorksHourHHMM(data.workingHours) ?? Strings.empty,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
          ],
        ));
  }

  loader() {
    return Obx(
        () => reportController.empAttendancesReportData.value.data != null
            ? reportController.empAttendancesReportData.value.data.length == 0
                ? Center(child: CircularProgressIndicator())
                : Center(child: CircularProgressIndicator())
            : Center(child: CircularProgressIndicator()));
  }

  noDataFound({String message}) {
    return Container(
      height: Get.height,
      child: Center(
          child: Text(message == null ? Strings.noRecordsFound : message)),
    );
  }

  filterWidget() {
    if (userType) {
      return Container(
        height: Get.height / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [fromWidget(), toWidget()],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [fromWidget(), toWidget()],
      );
    }
  }

  Widget exportData() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: Sizes.s10, horizontal: Sizes.s15),
        child: ElevatedButton(
          onPressed: () {
            // reportController.generateExampleDocument(
            //     reportController.attendanceData.value,
            //     Strings.attendanceReport);
          },
          style: buttonStyle(),
          child: CustomText(
            text: Strings.export,
          ),
        ),
      ),
    );
  }

  fromWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: Strings.from,
              fontSize: FontSizes.s16,
              fontWight: FontWeight.w400,
              color: AppColors.black,
            ),
            C10(),
            Obx(() {
              return Expanded(
                child: GestureDetector(
                    onTap: () async {
                      final DateTime selectedDate = await DateTimePicker
                          .selectDate(
                              Get.context,
                              DateTime.fromMillisecondsSinceEpoch(1000),
                              datePickerController
                                      .toDateString.value.text.isEmpty
                                  ? DateTime.now()
                                  : DateFormat("yyyy-MM-dd")
                                      .parse(
                                          datePickerController
                                              .toDateString.value.text),
                              lastDate: datePickerController
                                      .toDateString.value.text.isEmpty
                                  ? DateTime.now()
                                  : DateFormat("yyyy-MM-dd").parse(
                                      datePickerController
                                          .toDateString.value.text));
                      datePickerController.fromDateString.value.text =
                          DateFormat("yyyy-MM-dd").format(selectedDate);
                      this.reportController.exceedTime.value = false;
                      reportController.getAllEmployeeAttendanceData(
                          fDate: DateFormat("yyyy-MM-dd").format(selectedDate),
                          tDate: datePickerController.toDateString.value.text,
                          isMultipleUser: userType);
                    },
                    child: CustomDateWidget(
                        initialDate: DateTime.now(),
                        datePickerController:
                            datePickerController.fromDateString.value)),
              );
            })
          ],
        ),
      ),
    );
  }

  toWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: Strings.to,
              fontSize: FontSizes.s16,
              fontWight: FontWeight.w400,
              color: AppColors.black,
            ),
            C10(),
            Obx(() {
              return Expanded(
                child: GestureDetector(
                    onTap: () async {
                      final DateTime selectedDate =
                          await DateTimePicker.selectDate(
                              Get.context,
                              datePickerController
                                      .fromDateString.value.text.isNotEmpty
                                  ? DateFormat("yyyy-MM-dd").parse(
                                      datePickerController
                                          .fromDateString.value.text)
                                  : DateTime.fromMillisecondsSinceEpoch(1000),
                              DateTime.now(),
                              lastDate: DateTime.now());
                      datePickerController.toDateString.value.text =
                          DateFormat("yyyy-MM-dd").format(selectedDate);
                      this.reportController.exceedTime.value = false;
                      reportController.getAllEmployeeAttendanceData(
                          tDate: DateFormat("yyyy-MM-dd").format(selectedDate),
                          fDate: datePickerController.fromDateString.value.text,
                          isMultipleUser: userType);
                    },
                    child: CustomDateWidget(
                        width: Get.width * 0.37,
                        initialDate: DateTime.now(),
                        datePickerController:
                            datePickerController.toDateString.value)),
              );
            })
          ],
        ),
      ),
    );
  }

  getInTimeLocationWidget(String location,int index) {

    double lat,lon;
  try {
    reportController.inTimePlaceMarks.add(null);
    Map<String, dynamic> locationMap = json.decode(location);
    lat = locationMap["latitude"];
    lon = locationMap["longitude"];


    return FutureBuilder<List<Placemark>>(
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading...");
      } else {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
        reportController.addInLocationPlacemark(snapshot.data[index],index);

          return Text(
              "${snapshot.data.first.name},${snapshot.data.first.subLocality}, ${snapshot.data.first.locality}");
        }
      }
},
  future: placemarkFromCoordinates(lat, lon)
);
  }catch(ex){
    reportController.addInLocationPlacemark(null,index);
    return Text("");
  }
  }

  getOutTimeLocationWidget(String location,int index) {
    try {
      reportController.outTimePlaceMarks.add(null);
      double lat, lon;
      Map<String, dynamic> locationMap = json.decode(location);
      lat = locationMap["latitude"];
      lon = locationMap["longitude"];
      return FutureBuilder<List<Placemark>>(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            } else {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                reportController.addAddLocationPlacemark(snapshot.data[index],index);
                return Text(
                    "${snapshot.data.first.name},${snapshot.data.first
                        .subLocality}, ${snapshot.data.first.locality}");
              }
            }
          },
          future: placemarkFromCoordinates(lat, lon)
      );
    }catch(ex){
      reportController.addAddLocationPlacemark(null,index);
      return Text("");
    }
  }
}

// class AttendanceReport extends StatefulWidget {
//   const AttendanceReport({Key key}) : super(key: key);
//
//   @override
//   State<AttendanceReport> createState() => _AttendanceReportState();
// }
//
// class _AttendanceReportState extends State<AttendanceReport> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: CustomAppBar(
//           height: AppBar().preferredSize.height,
//           title:
//           Strings.attendanceReport,
//           textStyle: TextStyles.appBarTittle.copyWith(color: AppColors.white),
//           isBack: true,
//         ),
//       ),
//     );
//   }
// }

// Obx(() {
//   return GestureDetector(
//       onTap: () async {
//         final DateTime selectedDate = await DateTimePicker.selectDate(
//             Get.context,
//             DateTime.fromMillisecondsSinceEpoch(1000),
//             DateTime.now(),
//             lastDate: DateTime.now());
//         datePickerController.fromDateString.value.text =
//             DateFormat("yyyy-MM-dd").format(selectedDate);
//         this.reportController.exceedTime.value = false;
//         reportController.getAllEmployeeAttendanceData(
//             fDate: DateFormat("yyyy-MM-dd").format(selectedDate),
//             tDate: datePickerController.toDateString.value.text,
//             isMultipleUser: userType);
//       },
//       child: CustomDateWidget(
//         width: Get.width * 0.3522,
//         initialDate: DateTime.now(),
//         customTextStyle: TextStyles.defaultRegular.copyWith(
//             fontSize: FontSizes.s18, color: AppColors.white),
//         datePickerController:
//             datePickerController.fromDateString.value,
//       ));
// })

// Visibility(
//   visible: false,
//   child: Expanded(
//     child: Text(data.acceptance == 0 ? "Manual" : "Scanned"),
//   ),
// )

// Expanded(
//   flex: 1,
//     child: Row(
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InkWell(
//                 child: Icon(Icons.check_circle),
//                 onTap: (){
//                 }
//
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InkWell(
//                 child: Icon(Icons.close_rounded),
//                 onTap: (){
//
//                 }
//             ),
//           ),
//         ),
//       ],
//     )
// )

// return ListView.separated(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemBuilder: (context,index)=>customRowApproval(reportController.attendanceData.value.data[index],index),
//             separatorBuilder: (context,index){
//
//               return Container(
//                 margin: EdgeInsets.symmetric(horizontal: Sizes.s10),
//                 child: Divider(
//                   thickness: 0.2,
//                 ),
//               );
//
//               },
//              itemCount: reportController.attendanceData.value.data.length
//          );

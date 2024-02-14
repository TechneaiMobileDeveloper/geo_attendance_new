import 'package:flutter/material.dart';
import 'package:geo_attendance_system/models/InData.dart';
import '../../controllers/report_controller.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/ui/widgets/custom_date_widget.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '../../date_picker_controller.dart';

class AttendanceReport extends StatelessWidget {
  final userType;
  final reportController = Get.find<ReportController>();
  final datePickerController = Get.put(DatePickerController());
  final bool isTodayApproved;
  final int type;

  AttendanceReport(
      {Key key, this.userType = false, this.isTodayApproved = false, this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isTodayApproved)
      reportController.getAttendanceData(isMultipleUser: userType);

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: CustomText(
                  text: Strings.attendanceReport, fontSize: FontSizes.s16),
            ),
            body: GetX<ReportController>(
                initState: (s) => reportController.getAttendanceData(
                    isNotApproved: false, isMultipleUser: userType),
                builder: (c) => c.attendanceData.value != null
                    ? reportController.attendanceData.value.data != null
                        ? widgetAcceptance(userType)
                        : loader()
                    : noDataFound(message: Strings.somethingWentWrong))));
  }

  widgetAcceptance(bool isMultiuser) {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        if (!isMultiuser) C25(),
        C40(),
        if (!isMultiuser)
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [listHeader(), C10(), listBody()])
      ],
    );
  }

  listBody() {
    return GroupedListView<InData, String>(
      shrinkWrap: true,
      elements: isTodayApproved
          ? reportController.todayApproved.value.data.inData
          : type == Constants.AttendanceTypeIn
              ? reportController.attendanceData.value.data.inData
              : reportController.attendanceData.value.data.outData,
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
      indexedItemBuilder: (context, InData element, int index) =>
          customRowApproval(element, index),
      itemComparator: (item1, item2) => item1.date.compareTo(item2.date),
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
            Expanded(
                flex: 1,
                child: Text(
                  "Sr No",
                  textAlign: TextAlign.center,
                  style: TextStyles.textStyle
                      .copyWith(fontWeight: FontWeight.normal),
                )),
            Expanded(
                flex: 2,
                child: Text("Emp ID",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("Type",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("Name",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("Time",
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

  customRowApproval(InData data, int index) {
    return Container(
        padding: EdgeInsets.all(Sizes.s2),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text((index + 1).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
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
                    data.isMannualApprove.toString() == "0"
                        ? "${Strings.auto}-(${data.type})" //data.type
                        : "${Strings.manual}-(${data.type})",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text(data.userName ?? Strings.empty,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text(data.time ?? Strings.empty,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Visibility(
              visible: false,
              child: Expanded(
                child: Text(data.acceptance == 0 ? "Manual" : "Scanned"),
              ),
            )
          ],
        ));
  }

  loader() {
    return Obx(() => reportController.attendanceData.value.data != null
        ? reportController.attendanceData.value.data.inData.length == 0
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
  //
  // Widget exportData() {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: Padding(
  //       padding:
  //           EdgeInsets.symmetric(vertical: Sizes.s10, horizontal: Sizes.s15),
  //       child: ElevatedButton(
  //         onPressed: () {
  //           // reportController.generateExampleDocument(
  //           //     reportController.attendanceData.value,
  //           //     Strings.attendanceReport);
  //         },
  //         style: buttonStyle(),
  //         child: CustomText(
  //           text: Strings.export,
  //         ),
  //       ),
  //     ),
  //   );
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

        timeDifference = dtOutTime.difference(dtInTime).inMinutes.abs();
        log("timeDifference=$timeDifference");

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

  fromWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: Strings.from,
            fontSize: FontSizes.s16,
            fontWight: FontWeight.w400,
            color: AppColors.black,
          ),
          Obx(() {
            return Expanded(
              child: GestureDetector(
                  onTap: () async {
                    final DateTime selectedDate =
                        await DateTimePicker.selectDate(
                            Get.context,
                            DateTime.fromMillisecondsSinceEpoch(1000),
                            DateTime.now(),
                            lastDate: DateTime.now());
                    datePickerController.fromDateString.value.text =
                        DateFormat("yyyy-MM-dd").format(selectedDate);
                    this.reportController.exceedTime.value = false;
                    reportController.getAttendanceData(
                        fDate: DateFormat("yyyy-MM-dd").format(selectedDate),
                        tDate: datePickerController.toDateString.value.text,
                        isMultipleUser: userType);
                  },
                  child: CustomDateWidget(
                    initialDate: DateTime.now(),
                    customTextStyle: TextStyles.defaultRegular.copyWith(
                        fontSize: FontSizes.s18, color: AppColors.white),
                    datePickerController:
                        datePickerController.fromDateString.value,
                  )),
            );
          })
        ],
      ),
    );
  }

  toWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: Strings.to,
            fontSize: FontSizes.s16,
            fontWight: FontWeight.w400,
            color: AppColors.black,
          ),
          Obx(() {
            return GestureDetector(
                onTap: () async {
                  final DateTime selectedDate = await DateTimePicker.selectDate(
                      Get.context,
                      DateTime.fromMillisecondsSinceEpoch(1000),
                      DateTime.now(),
                      lastDate: DateTime.now());
                      datePickerController.toDateString.value.text =
                      DateFormat("yyyy-MM-dd").format(selectedDate);
                      this.reportController.exceedTime.value = false;
                      reportController.getAttendanceData(
                      tDate: DateFormat("yyyy-MM-dd").format(selectedDate),
                      fDate: datePickerController.fromDateString.value.text,
                      isMultipleUser: userType);
                },
                child: CustomDateWidget(
                    initialDate: DateTime.now(),
                    datePickerController:
                        datePickerController.toDateString.value));
          })
        ],
      ),
    );
  }

// appBar: CustomAppBar(
//           isHamburger: false,
//           color: AppColors.greyText,
//           textStyle: TextStyles.appBarTittle,
//           title: Strings.attendanceReport
//     ),
// floatingActionButton: Obx(
//   () => reportController.attendanceData.value.data != null
//       ? (type == Constants.AttendanceTypeIn
//               ? reportController
//                       .attendanceData.value.data.inData.length >
//                   0
//               : reportController
//                       .attendanceData.value.data.outData.length >
//                   0)
//           ? FloatingActionButton(
//               onPressed: () {
//                 // reportController.generateExampleDocument(
//                 //     reportController.attendanceData.value,
//                 //     Strings.attendanceReport);
//               },
//               child: Icon(Icons.download, color: AppColors.white),
//             )
//           : Container()
//       : Container(),
// ),

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
// Expanded(
//     flex: 2,
//     child: Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(data.outTime ?? Strings.notPunchedOut,
//           textAlign: TextAlign.center,
//           style: TextStyles.textStyle
//               .copyWith(fontWeight: FontWeight.normal)),
//     )),
// Expanded(
//     flex: 2,
//     child: Text(
//         "${getTimeDifferenceString(data.inTime, data.outTime)}" ??
//             Strings.empty,
//         textAlign: TextAlign.center,
//         style: TextStyles.textStyle
//             .copyWith(fontWeight: FontWeight.normal))),

//filterWidget(),
//C20(),
// if (!isMultiuser)
//   Container(
//     margin: EdgeInsets.symmetric(horizontal: Sizes.s10),
//     child: AppTextField(
//       isBoarder: false,
//       decoration: InputDecoration(
//         hintText: "Search user",
//         counterText: '',
//         counter: null,
//         border: OutlineInputBorder(
//             borderSide:
//                 BorderSide(color: Colors.blueAccent, width: 32.0),
//             borderRadius: BorderRadius.circular(Sizes.s18)),
//         contentPadding: EdgeInsets.symmetric(
//             vertical: Sizes.s12, horizontal: Sizes.s10),
//         hintStyle:
//             TextStyles.defaultRegular.copyWith(fontSize: FontSizes.s15),
//       ),
//       inputFormatters: <TextInputFormatter>[
//         FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
//       ],
//       keyboardType: TextInputType.text,
//       onTextChanged: (val) {
//         reportController.filterReport(val);
//         //initMethods(text: val);
//       },
//       suffixIcon: Icon(Icons.search, color: AppColors.black),
//     ),
//   ),

// Expanded(
//     flex: 2,
//     child: Text("OutTime",
//         textAlign: TextAlign.center,
//         style: TextStyles.textStyle
//             .copyWith(fontWeight: FontWeight.normal))),
// Expanded(
//     flex: 2,
//     child: Text("WHours",
//         textAlign: TextAlign.center,
//         style: TextStyles.textStyle
//             .copyWith(fontWeight: FontWeight.normal))),

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

// :
//                 loader()
// ),
}

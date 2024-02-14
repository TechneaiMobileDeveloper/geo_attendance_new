import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/style/style.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';

class ApprovedReport extends StatelessWidget {
  final reportController = Get.find<ReportController>();

  ApprovedReport({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    reportController.getAttendanceDataModelisTodayApproved(
        isTodayApproved: true);

    print("scaffold......");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: Strings.approvedReport,
            fontSize: FontSizes.s16,
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // reportController.generateExampleDocument(
        //     //     reportController.attendanceData.value,
        //     //     Strings.attendanceReport);
        //   },
        //   child: Icon(Icons.download),
        // ),
        body: Obx(() => reportController.attendancesDataModel.value != null
            ? reportController.attendancesDataModel.value.data != null
                ? widgetAcceptance()
                : loader()
            : loader()),
      ),
    );
  }

  loader() {
    reportController.startTimer();
    return Obx(() => !reportController.exceedTime.value
        ? Center(child: CircularProgressIndicator())
        : noDataFound());
  }

  /* root view of widget */

  widgetAcceptance() {
    print("widget acceptances");
    print(
        "widget acceptances :: ${reportController.attendancesDataModel.value.data.length}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.s5, vertical: Sizes.s10),
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          Obx(() => !reportController.exceedTime.value
              ? reportController.attendancesDataModel.value != null
                  ? reportController.attendancesDataModel.value.data != null
                      ? reportController
                                  .attendancesDataModel.value.data.length >
                              0
                          ? Column(children: [listHeader(), listBody()])
                          : loader()
                      : noDataFound()
                  : noDataFound()
              : noDataFound(message: Strings.somethingWentWrong)),
        ],
      ),
    );
  }

  listBody() {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => customRowApproval(index),
        separatorBuilder: (context, index) {
          return Divider(thickness: 1);
        },
        itemCount: reportController.attendancesDataModel.value.data.length);
  }

  listHeader() {
    print("hu..listheader");
    return Container(
        height: Sizes.s50,
        color: AppColors.greyText,
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Sr No",
                  textAlign: TextAlign.center,
                  style: TextStyles.textStyle
                      .copyWith(fontWeight: FontWeight.normal),
                )),
            Expanded(
                flex: 2,
                child: Text("Date",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
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
                child: Text("Emp Name",
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
                child: Text("Status",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
          ],
        ));
  }

  widgetTitle(String title) {
    return Text(title, style: TextStyle(fontSize: FontSizes.s13));
  }

  customRowApproval(int index) {
    var dataModel = reportController.attendancesDataModel.value.data[index];

    return Container(
        child: Row(
      children: [
        Expanded(
            flex: 2,
            child: Text((index + 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(dataModel.date.toString() ?? Strings.empty,
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(dataModel.type.toString() ?? Strings.empty,
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(dataModel.empId.toString().toString(),
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(dataModel.userName.toString().toString(),
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(dataModel.time.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal)),
                InkWell(
                  onTap: () => showImage(dataModel.imagePath.toString()),
                  child: Text("View Image",
                      textAlign: TextAlign.center,
                      style: TextStyles.textStyle.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.blueAccent,
                          fontSize: FontSizes.s12)),
                ),
              ],
            )),
        Expanded(
            flex: 2,
            child: Text(
                dataModel.acceptance.toString() == "1"
                    ? "Accept" //data.type
                    : "Reject",
                textAlign: TextAlign.center,
                style: TextStyles.textStyle.copyWith(
                    fontWeight: FontWeight.normal,
                    color: dataModel.acceptance.toString() == "1"
                        ? AppColors.green
                        : AppColors.red))),
      ],
    ));
  }

  noDataFound({String message}) {
    return Center(
      child: Text(Strings.noRecordsFound),
    );
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
              //     reportController.attendanceData.value, Strings.approve);
            },
            style: buttonStyle(),
            child: CustomText(
              text: Strings.export,
            ),
          ),
        ));
  }

  showImage(String url) {
    SettingController settingController = Get.find();
    url = url.replaceAll(
        Strings.privateIp,
        settingController.getIp() ??
            AppUrl.urlBase().replaceAll("http://", ""));

    Get.dialog(SimpleDialog(
      title: CustomText(
          text: Strings.imagePreview,
          fontSize: Sizes.s15,
          fontWight: FontWeight.bold),
      children: [
        ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: Get.height / 2, minWidth: Get.width * 0.8),
            child: url.contains("http://")
                ? Image.network(url)
                : getImageWidget(url))
      ],
    ));
  }

  Widget getImageWidget(String url) {
    try {
      final byteImage = Base64Decoder().convert(url);
      return Image.memory(byteImage);
    } catch (ex) {
      return Container();
    }
  }

// void startTimer() {
//   _timer = Timer.periodic(Duration(seconds: 5),
//           (timer) {
//             reportController.exceedTime.value = true;
//             _timer.cancel();
//         });
// }
}

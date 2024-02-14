import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/style/style.dart';
import 'package:geo_attendance_system/ui/widgets/confirm_dialog.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';

import '../../models/Data.dart';

class Acceptance extends StatelessWidget {
  final reportController = Get.find<ReportController>();

  Acceptance({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    reportController.getAttendanceData(isNotApproved: true);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: Strings.acceptance,
            fontSize: FontSizes.s16,
          ),
        ),

        body: Obx(() => reportController.attendanceData.value != null
            ? reportController.attendanceData.value.data != null
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.s5, vertical: Sizes.s10),
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          Obx(() => !reportController.exceedTime.value
              ? reportController.attendanceData.value != null
                  ? reportController.attendanceData.value.data != null
                      ? reportController.attendanceData.value.data.inData.length > 0
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
        itemBuilder: (context, index) => customRowApproval(
            reportController.attendanceData.value.data, index),
           // reportController.attendanceData.value.data.inData[index], index),
        separatorBuilder: (context, index) {
          return Divider(thickness: 1);
        },
    itemCount: reportController.attendanceData.value.data.inData.length);

  }

  listHeader() {
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
                child: Text("OutTime",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text("Action",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal)))
          ],
        ));
  }

  widgetTitle(String title) {
    return Text(title, style: TextStyle(fontSize: FontSizes.s13));
  }

  customRowApproval(Data data, int index) {
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
            child: Text(data.inData[index].date,
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(data.inData[index].empId.toString(),
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),
        Expanded(
            flex: 2,
            child: Text(data.inData[index].userName.toString(),
                textAlign: TextAlign.center,
                style: TextStyles.textStyle
                    .copyWith(fontWeight: FontWeight.normal))),

        Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(data.inData[index].time,
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal)),
                InkWell(
                  onTap: () => showImage(data.inData[index].imagePath),
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
            child: Column(
              children: [
                Text(
                  //  "NA",
                data.inData[index].time != null ? data.inData[index].time : "NA",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal)),

              ],
            )),

        Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  onTap: () {
                    confirm(Get.context, data,index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.check_circle, size: FontSizes.s20),
                  ),
                ),
                Visibility(
                  visible: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.s10),
                    child: Container(
                      color: Colors.red,
                      width: Sizes.s18,
                      height: Sizes.s18,
                      child: InkWell(
                        onTap: () {
                          reject(Get.context, data,index);
                        },
                        child: Center(
                            child: Icon(Icons.close, size: FontSizes.s20)),
                      ),
                    ),
                  ),
                ),
              ],
            ))
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
                : getImageWidget(url)
        )],
    ));
  }

  void confirm(
    BuildContext context,
    Data data,
      int index
  ) {
    showDialog(
        context: context,
        builder: (context) => ConfirmDialog(
              onNo: () {
                Get.back();
              },
              onYes: () {
                reportController.approveAttendance(data,index);
                Get.back();
              },
              message: Strings.areYouSureWantAcceptAttendance,
            ));
  }

  void reject(BuildContext context, Data data,int index) {
    showDialog(
        context: context,
        builder: (context) => ConfirmDialog(
              onNo: () {
                Get.back();
              },
              onYes: () {
               reportController.rejectApprove(data,index);
                Get.back();
              },
             message: Strings.areYouSureWantRejectAttendance,
            ));
  }

 Widget getImageWidget(String url) {
    try {
      final byteImage = Base64Decoder().convert(url);
      return Image.memory(byteImage);
    }catch(ex){
      return Container();

    }
 }

// Visibility(
//     visible: data.outData[index].time != null ? true : false,
//     child: InkWell(
//       onTap: () => showImage(data.outData[index].imagePath),
//       child: Text("View Image",
//           textAlign: TextAlign.center,
//           style: TextStyles.textStyle.copyWith(
//               fontWeight: FontWeight.normal,
//               color: Colors.blueAccent,
//               fontSize: FontSizes.s12)),
//     ))

// void startTimer() {
//   _timer = Timer.periodic(Duration(seconds: 5),
//           (timer) {
//             reportController.exceedTime.value = true;
//             _timer.cancel();
//         });
// }
}

// Expanded(
//     flex: 2,
//     child: Column(
//       children: [
//         Text(data.outData[index].time,
//             textAlign: TextAlign.center,
//             style: TextStyles.textStyle
//                 .copyWith(fontWeight: FontWeight.normal)),
//         InkWell(
//           onTap: () => showImage(data.outData[index].imagePath),
//           child: Text("View Image",
//               textAlign: TextAlign.center,
//               style: TextStyles.textStyle.copyWith(
//                   fontWeight: FontWeight.normal,
//                   color: Colors.blueAccent,
//                   fontSize: FontSizes.s12)),
//         ),
//       ],
//     )),

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:geo_attendance_system/controllers/report_controller.dart';
// import 'package:geo_attendance_system/models/attendance_data.dart';
// import 'package:geo_attendance_system/res/res_controller.dart';
// import 'package:geo_attendance_system/utils/utils_controller.dart';
// import 'package:get/get.dart';
//
// class Acceptance extends StatelessWidget {
//
//   final reportController = Get.put(ReportController(true));
//   //Timer _timer;
//
//   Acceptance({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//               appBar: CustomAppBar(
//                        isHamburger: false,
//                        title: Strings.acceptance
//               ),
//               body:   Obx(
//                       ()=> reportController.attendanceData.value.data != null ? widgetAcceptance() :loader()
//               ),
//       ),
//     );
//   }
//   loader() {
//     reportController.startTimer();
//      return Obx(()=>!reportController.exceedTime.value ? Center(child: CircularProgressIndicator()):noDataFound());
//   }
//
//   /* root view of widget */
//
//   widgetAcceptance() {
//     return Obx(() => ! reportController.exceedTime.value ?
//                        reportController.attendanceData.value.data != null ?
//                        reportController.attendanceData.value.data.length > 0  ?   ListView(
//                       children: [
//                          listHeader(),
//                           listBody()
//                       ]
//                   ):
//                        loader(): noDataFound():noDataFound()
//     );
//   }
//
//   listBody(){
//     return ListView.separated(
//                         shrinkWrap: true,
//                         itemBuilder: (context,index)=>customRowApproval(reportController.attendanceData.value.data[index],index),
//                         separatorBuilder: (context,index){
//                              return Divider(
//                                thickness: 1,
//                              );
//                      }, itemCount: reportController.attendanceData.value.data.length);
//   }
//
//   listHeader(){
//     return Container(
//              padding: EdgeInsets.all(Sizes.s8),
//         child:Row(
//             children: [
//                 Expanded(
//                 flex:1,
//                 child:Text("Sr No",
//                   textAlign: TextAlign.center,
//                   style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold),
//                 )
//             ),
//                 Expanded(
//                 flex:1,
//                 child:Text("Date",
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold)
//                 )
//             ),
//                 Expanded(
//                 flex:1,
//                 child:Text("Emp ID",
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold))
//             ),
//                 Expanded(
//                 flex:1,
//                 child:Text("InTime",
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold))
//             ),
//                 Expanded(
//                 child: Text("OutTime",
//                             textAlign: TextAlign.center,
//                              style:   TextStyles.textStyle.copyWith(
//                                         fontWeight: FontWeight.bold
//                              )
//                 )
//             ),
//                 Expanded(
//                 child: Text("Action",
//                               textAlign: TextAlign.center,
//                                style: TextStyles.textStyle.copyWith(
//                                     fontWeight: FontWeight.bold
//                              )
//                   )
//             )
//           ],
//         )
//     );
//   }
//
//   widgetTitle(String title) {
//     return Text(
//                 title,
//                 style: TextStyle(
//                       fontSize: FontSizes.s13
//                 )
//     );
//   }
//
//   customRowApproval(Data data,int index) {
//     return Container(
//              padding: EdgeInsets.all(Sizes.s8),
//              child:Row(
//              children: [
//                Expanded(
//                 flex:1,
//                 child:Text((index+1).toString(),textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.normal))
//             ),
//                Expanded(
//                 flex:1,
//                 child:Text(data.cDate,textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.normal))),
//                Expanded(
//                 flex:1,
//                 child:Text(data.empId.toString(),
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.normal)
//                 )
//             ),
//                Expanded(
//                 child: Text(data.inTime,
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.normal)
//                 )
//             ),
//                Expanded(
//                 child: Text(data.outTime,
//                     textAlign: TextAlign.center,
//                     style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.normal))
//             ),
//                Expanded(
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: (){
//                         reportController.approveAttendance(data);
//                       },
//                       child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(Icons.check_circle),
//                       ),
//                     ),
//
//                     Visibility(
//                       visible: false,
//                       child: InkWell(
//                         onTap: (){
//
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Icon(Icons.close_rounded),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//             )
//           ],
//         )
//     );
//   }
//
//   noDataFound() {
//     return Center(
//       child: Text(Strings.noRecordsFound),
//     );
//   }
//
//   // void startTimer() {
//   //   _timer = Timer.periodic(Duration(seconds: 5),
//   //           (timer) {
//   //             reportController.exceedTime.value = true;
//   //             _timer.cancel();
//   //         });
//   // }
// }

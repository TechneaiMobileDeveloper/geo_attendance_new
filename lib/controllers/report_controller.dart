import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geo_attendance_system/controllers/attendance_controller.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/models/attendance_data_1.dart';
import 'package:geo_attendance_system/models/attendance_data.dart' as c;
import 'package:geo_attendance_system/models/attendances_report/attendances_report_model.dart'
    as r;
import 'package:geo_attendance_system/models/calender_report/calender_report_model.dart';
import 'package:geo_attendance_system/models/calender_report/calender_report_model.dart'
    as emp;
import 'package:geo_attendance_system/models/employee_list_model.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/repository/attendance_report_repository.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/service/LocalNotificationService.dart';
import 'package:geo_attendance_system/ui/widgets/custom_drop_down.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/attendances_report/attendances_report_model.dart';
import '../ui/widgets/custom_text_widget.dart';

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class ReportController extends GetxController {
  DataBaseService apiService;

  List<Placemark> inTimePlaceMarks = [];
  List<Placemark> outTimePlaceMarks = [];

  APIClient apiClient = new APIClient();

  AttendanceController attendanceController;

  AttendanceReportRepository attendanceReportRepository;
  final exceedTime = false.obs;
  final isLoading = false.obs;
  final todayApproved = c.AttendanceData().obs;

  final attendanceData = c.AttendanceData().obs;

  final attendancesDataModel = AttendanceDataModel().obs;
  final todayApprovedModel = AttendanceDataModel().obs;

//  final empAttendancesReportData = r.Data().obs;

  final empAttendancesReportData = r.AttendanceReportModel().obs;
  var empAttendanceList = r.AttendanceReportModel().data;
  final todayApprovedemp = AttendanceReportModel().obs;

  // final todayApprovedemp = r.Data().obs;

  final calenderEmployeeModle = emp.CalenderReportModel().obs;

  final sheetEmployeeList = <Map<String, dynamic>>[].obs;

  // final employeeList = <Data>[].obs;
  final employeeList = emp.CalenderReportModel().obs;
  final isNotApproved = false.obs;
  final service = FlutterBackgroundService().obs;

  //todo comment when testing
  final LocalNotificationService localnotification = Get.find();

  Timer _timer;

  final dateController = TextEditingController(
          text: DateFormat("dd-MM-yyyy").format(DateTime.now()))
      .obs;

  //RxList<DropdownMenuItem<DropDownModal>> dropDownEmployeeList = <DropdownMenuItem<DropDownModal>>[].obs;
  final dropDownEmployeeList =
      List<DropdownMenuItem<DropDownModal>>.empty().obs;

  Rx<DropDownModal> selectedEmployee = DropDownModal().obs;

  //DropDownModal? selectedBank = DropDownModal("select type", 0);
  ReportController(bool isNotApproved) {
    this.isNotApproved.value = isNotApproved;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function
  final didReceiveLocalNotificationSubject = <ReceivedNotification>[].obs;

  final selectNotificationSubject = "".obs;

  static const MethodChannel platform =
      MethodChannel('dexterx.dev/flutter_local_notifications_example');
  String selectedNotificationPayload;

  @override
  void onInit() {
    //todo comment when testing
    apiService = DataBaseService();
    attendanceData.value = null;
    getAttendanceData();
    super.onInit();
  }

// this method will give attendance data of employee
  /* @param isTodayApproved = true ;gives total approved result
   @param isNotApproved = true ;gives total manual punch result
   @param fdate = from Date
   @param tdate = to Date

  */
  // is Not Approved

  Future<void> getAttendanceData(
      {String tDate,
      String fDate,
      bool isTodayApproved = false,
      bool isNotApproved = false,
      bool isMultipleUser = false}) async {
    try {
      this.attendanceData.value = c.AttendanceData();
      Map<String, dynamic> body = {};
      var date = await dashboardController.getCurrentDate(Strings.yyyyMMdd);
      if (!isNotApproved && (!isTodayApproved)) {
        body['f_date'] = fDate == null ? date : fDate;
        body['tdate'] = tDate == null ? date : tDate;
        body['acceptance'] = 1;
      } else if (isNotApproved && (!isTodayApproved)) {
        body['f_date'] = date;
        body['acceptance'] = 0;
      }

      if (!isMultipleUser) {
        attendanceData.value = await apiService.getAttendanceData(body,
            isTodayApproved: isTodayApproved);
        if (isTodayApproved) todayApproved.value = attendanceData.value;
      } else {
        if (fDate == null && tDate == null) {
          final dashboardController = Get.put(DashboardController(true));
          fDate = await dashboardController.getTime();
          tDate = fDate;
        }
        //c.AttendanceData mAttendanceDataList = c.AttendanceData();
      }

      if (_timer != null) _timer.cancel();
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> getAttendanceDataModelisTodayApproved(
      {String tDate,
      String fDate,
      bool isTodayApproved = false,
      bool isNotApproved = false,
      bool isMultipleUser = false}) async {
    try {
      print("getAttendanceDataModelisTodayApproved :: $isNotApproved");
      this.attendancesDataModel.value = AttendanceDataModel();
      Map<String, dynamic> body = {};
      var date = await dashboardController.getCurrentDate(Strings.yyyyMMdd);
      if (!isNotApproved && (!isTodayApproved)) {
        body['f_date'] = fDate == null ? date : fDate;
        body['tdate'] = tDate == null ? date : tDate;
      } else if (isNotApproved && (!isTodayApproved)) {
        body['f_date'] = date;
        body['acceptance'] = 0;
      }

      if (!isMultipleUser) {
        // attendancesDataModel.value = await apiService.getAttendanceData(body,
        //     isTodayApproved: isTodayApproved);

        attendancesDataModel.value = await apiService
            .getAttendanceDataReport(body, isTodayApproved: isTodayApproved);

        if (isTodayApproved)
          todayApprovedModel.value = attendancesDataModel.value;
      } else {
        if (fDate == null && tDate == null) {
          final dashboardController = Get.put(DashboardController(true));
          fDate = await dashboardController.getTime();
          tDate = fDate;
        }

        c.AttendanceData mAttendanceDataList = c.AttendanceData();
      }

      if (_timer != null) _timer.cancel();
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> getAllEmployeeAttendanceData(
      {String tDate,
      String fDate,
      bool isTodayApproved = false,
      bool isNotApproved = false,
      bool isMultipleUser = false}) async {
    try {
      this.empAttendancesReportData.value = r.AttendanceReportModel();
      Map<String, dynamic> body = {};
      var date = await dashboardController.getCurrentDate(Strings.yyyyMMdd);

     //  !isNotApproved = true && (!isTodayApproved);

      if (!isNotApproved && (!isTodayApproved)) {

        body['emp_id'] = '';
        body['f_date'] = fDate == null ? date : fDate;
        body['t_date'] = tDate == null ? date : tDate;
        body['acceptance'] = 1;
      } else if (isNotApproved && (!isTodayApproved)) {
        body['f_date'] = date;
        body['acceptance'] = 0;
      }

      if (!isMultipleUser) {

        empAttendancesReportData.value =
            await apiService.getAllEmployeeAttendanceReportData(body,
                isTodayApproved: isTodayApproved);
        empAttendanceList = empAttendancesReportData.value.data;
        //    print("body $body");
        print("body data ::${empAttendancesReportData.value.data}");
        print("if ::: $isMultipleUser");
        if (isTodayApproved)
          todayApprovedemp.value = empAttendancesReportData.value;
        //if (isTodayApproved) todayApprovedemp.value = empAttendancesReportData.value ?? "";
      } else {
        if (fDate == null && tDate == null) {
          final dashboardController = Get.put(DashboardController(true));
          fDate = await dashboardController.getTime();
          tDate = fDate;
        }

        print("else ::: if");

        r.AttendanceReportModel mAttendanceData = r.AttendanceReportModel();

        mAttendanceData.status = 0;
      }

      if (_timer != null) _timer.cancel();
    } catch (ex) {
      print(ex.toString());
    }
  }

  viewCalenderReport(String empId, String fDate, {String url}) async {
    try {
      //  dropDownEmployeeList.clear();
      //   selectedEmployee.value = dropDownEmployeeList.first.value;
      Map<String, dynamic> body = {};
      body['empid'] = empId;
      body['date'] = fDate;

      print("response calender Report Details :: ..........body $body");
      CalenderReportModel response = await calenderReportDetails(body);

      //todo - uncomment when testing
      // CalenderReportModel response = await calenderReportDetails(body,url: url);

      print("calender message :: ${response.message}");
      print("calender status :: ${response.status}");
      print("calender data :: ${response.data.total}");
      this.calenderEmployeeModle.value = response;

      log("viewCalenderReport:${json.encode(this.calenderEmployeeModle.value)}");
    } on Exception catch (ex) {
      print(ex);
      Common.toast(ex.toString());
    }
  }

  viewCalenderReport2(String empId, String fDate) async {
    try {
      Map<String, dynamic> body = {};
      body['empid'] = empId;
      body['date'] = fDate;

      print("response calender Report Details :: ..........body $body");
      CalenderReportModel response = await calenderReportDetails(body);
      print("calender message :: ${response.message}");
      print("calender status :: ${response.status}");
      print("calender data :: ${response.data.total}");
      this.calenderEmployeeModle.value = response;

      dropDownEmployeeList.clear();
      print("length :: ${response.data.employee.length}");
      for (int i = 0; i < response.data.employee.length; i++) {
        print("length :: ${response.data.employee.length}");
        DropDownModal dropDownModal = DropDownModal(
            name: response.data.employee[i].employee,
            index: response.data.employee[i].empId);
        dropDownEmployeeList.add(DropdownMenuItem(
          value: dropDownModal,
          child: CustomText(text: dropDownModal.name),
        ));
      }
      //   selectedEmployee.value ;
      //print("selectedEmployee :: ${selectedEmployee.value}");
    } on Exception catch (ex) {
      print(ex);
      Common.toast(ex.toString());
    }
  }

  Future<CalenderReportModel> calenderReportDetails(Map<String, dynamic> body,
      {String url}) async {
    try {
      print("Calender Report");
      String calenderReportUrl;
      if (url == null) {
        final settingController = Get.find<SettingController>();
        calenderReportUrl =
            await getIpAddress(settingController: settingController);
      } else {
        calenderReportUrl = url;
      }
      //   final calenderReportUrl = AppUrl.urlBase() + AppUrl.getCalenderReport;
      calenderReportUrl = calenderReportUrl + AppUrl.getCalenderReport;
      print("Calender Report ::  $calenderReportUrl");
      Map<String, dynamic> response = await apiClient.post(
        calenderReportUrl,
        data: body,
        headers: {"Content-Type": "application/json"},
      );

      return CalenderReportModel.fromJson(response);
    } catch (ex) {
      print("Error=${ex.toString()}");
    }
  }

  employeeModelListReport() async {
    //Get.dialog(LoadingDialog(), barrierDismissible: false);
    try {
      Map<String, dynamic> body = {};
      print("Employee");
      EmployeeModel response = await employeeModelDetails(body);

      print("Employee message :: ${response.message}");
      //  print("Employee data :: ${response.data.first.employee}");

    } on Exception catch (ex) {
      print(ex);
      Common.toast(ex.toString());
    }
  }

  Future<EmployeeModel> employeeModelDetails(Map<String, dynamic> body) async {
    try {
      print("Employee Model");
      final settingController = Get.find<SettingController>();
      String calenderReportUrl =
          await getIpAddress(settingController: settingController);
      //   final calenderReportUrl = AppUrl.urlBase() + AppUrl.getCalenderReport;
      calenderReportUrl = calenderReportUrl + AppUrl.getAllEmployee;
      print("Employee Modle ::  $calenderReportUrl");
      Map<String, dynamic> response = await apiClient.post(
        calenderReportUrl,
        data: body,
        headers: {"Content-Type": "application/json"},
      );

      return EmployeeModel.fromJson(response);
    } catch (ex) {
      print("Error=${ex.toString()}");
    }
  }

  getReportData() async {
    try {
      bool hasInternet = await hasNetwork();
    } on Exception {}
  }

  void startTimer() {
    try {
      _timer = Timer.periodic(Duration(seconds: 30), (timer) {
        this.exceedTime.value = true;
        _timer.cancel();
      });
    } catch (ex) {}
  }

  Future<void> generateExampleDocument(
      AttendanceReportModel attendanceData, String fileName) async {
    String path;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (attendanceData.data.isNotEmpty) {
      List<List<dynamic>> rows = [];

      List<dynamic> row = [];

      row.add("Sr No");
      row.add("date");
      row.add("Emp Id");
      row.add("Name");
      row.add("InTime");
      row.add("OutTime");
      row.add("inLocation");
      row.add("outLocation");
      row.add("WHours");
      rows.add(row);

      for (int i = 0; i < attendanceData.data.length; i++) {
        List<dynamic> row = [];

        row.add(i + 1);
        row.add(attendanceData.data[i].date);
        row.add(attendanceData.data[i].empId);
        row.add(attendanceData.data[i].empName);
        row.add(attendanceData.data[i].inTime);
        row.add(attendanceData.data[i].outTime);
        if(inTimePlaceMarks[i] != null)
          row.add("${inTimePlaceMarks[i].name} ${inTimePlaceMarks[i].subLocality} ${inTimePlaceMarks[i].locality}");
        else
          row.add("NA");
       if(outTimePlaceMarks[i] != null)
          row.add("${outTimePlaceMarks[i].name} ${outTimePlaceMarks[i].subLocality} ${outTimePlaceMarks[i].locality}");
        else
          row.add("NA");
        row.add(timeFormatter(attendanceData.data[i].workingHours) );
        // row.add(getTimeDifferenceString(
        //     attendanceData.data[i].inTime, attendanceData.data[i].outTime));
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);

      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      print("dir $path");
      String file = path;

      File f = File(file +
          "/${fileName}_${DateFormat("yyyy-dd-M--HH-mm-ss").format(DateTime.now())}.csv");
      if (!f.existsSync()) {
        f.createSync();
      }
      Timer.periodic(Duration(microseconds: 1), (timer) async {
        String fileString = await f.readAsString();
        double percentage = ((fileString.length / csv.length) * 100);
        if (percentage < 0.99) {
          localnotification.showLocal(Strings.downloading, "$percentage",
              payloadMsg: {"path": f.path});
        } else {
          localnotification.showLocal(Strings.downloading, "100%",
              payloadMsg: {"path": f.path});
          timer.cancel();
        }
      });
      await f.writeAsString(csv);
      Common.toast(Strings.downloaded_successfully);
    } else {
      Common.toast(Strings.noRecordsFound);
    }
  }

  // Time Difference of two date

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
          return "-";

        if (inTime != null)
          dtInTime = _format.parse(inTime);
        else
          return "-";

        timeDifference = dtOutTime.difference(dtInTime).inMinutes;
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

  void filterReport(String val) {
    if (attendanceData.value.data != null && val.isNotEmpty) {
      print("filter Report");
      c.AttendanceData mAttendanceData = c.AttendanceData();
      mAttendanceData.success = true;
      mAttendanceData.message = "";
      // mAttendanceData.data.value = attendanceData.value.data
      //     .where((element) =>
      //         element.userName.toLowerCase().contains(val.toLowerCase()) ||
      //         element.empId.toString().contains(val))
      //     .toList();
      attendanceData.value = mAttendanceData;
      print("filter ;; $val");
    } else {
      getAttendanceData();
    }
  }

  void allEmployeeFilterReport(String val,
      {Rx<TextEditingController> fromDate, Rx<TextEditingController> toDate}) {
    print("filter");

    if (empAttendancesReportData.value.data != null && val.isNotEmpty) {
      empAttendancesReportData.value.data = empAttendanceList;
      print("filter Report");

      r.AttendanceReportModel mAttendanceData = r.AttendanceReportModel();

      mAttendanceData.status = 1;
      mAttendanceData.message = "";

      print("filter message ${mAttendanceData.message.toString()}");

      mAttendanceData.data = empAttendancesReportData.value.data
          .where((element) =>
              element.empName.toLowerCase().contains(val.toLowerCase()) ||
              element.empId.toString().contains(val))
          .toList();

      empAttendancesReportData.value = mAttendanceData;
      print("filter ;; $val");
    } else {
      // todo format
      // fromDate.value.text =
      //     DateTimeFormatter.displayYYYYMMDD.format(DateTime.now());
      // toDate.value.text =
      //     DateTimeFormatter.displayYYYYMMDD.format(DateTime.now());
      getAllEmployeeAttendanceData(
          fDate: fromDate.value.text, tDate: toDate.value.text);
    }
  }

  void onResponseGetLocationDetails(Map<String, dynamic> value) {
    if (kDebugMode) {
      print(json.encode(value));
    }
//    r.AttendanceReportModel details = r.AttendanceReportModel.fromJson(value);
    // empAttendancesReportData.value = details.data as r.Data;

    r.AttendanceReportModel details = r.AttendanceReportModel.fromJson(value);
    empAttendancesReportData.value = details.data as r.AttendanceReportModel;
    Common.toast(value['message']);
  }

  void approveAttendance(data, int index) async {
    try {
      var empId = data[index].empId;
      var date = data[index].date.toString();
      var type = data[index].type.toString();
      var time = data[index].time;
      print("approval data $empId  :: date :: $date :: type : $type");
      this.isLoading.value = true;
      await apiService.approveAttendance(
          empId, date.toString(), type.toString(), time);

      // await getAllEmployeeAttendanceData(isNotApproved: true);
      ///// reportController.getAttendanceDataModelisTodayApproved(isNotApproved: true);
      await getAttendanceDataModelisTodayApproved(isNotApproved: true);
      //  await getAllEmployeeAttendanceDatavalue(isNotApproved: true);
      this.isLoading.value = false;
    } catch (ex) {
      log(ex.toString());
    }
  }

  void rejectApprove(data, int index) async {
    try {
      print("reject ${data[index].empId.toString()}");
      var empId = data[index].empId;
      var date = data[index].date.toString();
      var type = data[index].type.toString();
      var time = data[index].time.toString();
      print("reject IN .. $empId");
      print("reject data $empId  :: date :: $date ,, type : $type");
      this.isLoading.value = true;
      await apiService.rejectAttendance(empId, date, type, time);
      //await getAllEmployeeAttendanceDatavalue(isNotApproved: true);
      await getAttendanceDataModelisTodayApproved(isNotApproved: true);
      this.isLoading.value = false;
    } catch (ex) {
      log(ex.toString());
    }
  }

  String timeFormatter(dynamic time) {
    Duration duration = Duration(milliseconds: double.parse(time.toString()).round());
    return [duration.inHours, duration.inMinutes]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String getWorksHourHHMM(dynamic workingHours) {
    try {
      if (workingHours != 0) {
        dynamic milliseconds = workingHours  * 60 * 1000;
        String time = timeFormatter(milliseconds);
        return "$time h";
      } else {
        return "00:00 h";
      }
    } catch (ex) {
      if (kDebugMode) {
        Common.toast(
            "ReportController:getWorksHourHHMM:Line NO-894${ex.toString()}");
      }
      return "NA";
    }
  }
  // add inTime attendance location
  void addInLocationPlacemark(Placemark first, int index) {
    try{
     if(inTimePlaceMarks.isEmpty){
       inTimePlaceMarks.add(first);
     }
     else if(inTimePlaceMarks[index] == null){
         inTimePlaceMarks[index] = first;
      }
      else{
        inTimePlaceMarks.add(first);
      }
    }
    catch(ex){
      print(ex);
    }
  }

  void addAddLocationPlacemark(Placemark first, int index) {
    try{
      if(outTimePlaceMarks.isEmpty){
        outTimePlaceMarks.add(first);
      }
      else if(outTimePlaceMarks[index] != null){
        outTimePlaceMarks[index] = first;
      }
      else{
        outTimePlaceMarks.add(first);
      }
    }
    catch(ex){
      print(ex);
    }
  }

// if (empAttendancesReportData.value != null) {
//   if (empAttendancesReportData.value.data != null) {
//     if (empAttendancesReportData.value.data.length > 0) {
//       empAttendancesReportData.value.data.sort((a, b) {
//         return a.empId != null && b.empId != null
//             ? a.empId.compareTo(b.empId)
//             : 1;
//       });
//     }
//   }
// }

// void approveAttendance(data,int index) async {
//   try {
//
//     var empId = data.inData[index].empId;
//     var date = data.inData[index].date.toString();
//     print("approval data ${empId}  :: date :: ${date}");
//     this.isLoading.value = true;
//
//     await apiService.approveAttendance(empId, date.toString());
//     await getAttendanceData(isNotApproved: true);
//     this.isLoading.value = false;
//   } catch (ex) {
//     log(ex.toString());
//   }
// }
//
// void rejectApprove(data, int index) async {
//   try {
//     var empId = data.inData[index].empId;
//     var date = data.inData[index].date.toString();
//     print("reject data ${empId}  :: date :: ${date}");
//     this.isLoading.value = true;
//     await apiService.rejectAttendance(empId, date);
//     await getAttendanceData(isNotApproved: true);
//     this.isLoading.value = false;
//   } catch (ex) {
//     log(ex.toString());
//   }
// }

// sendDownloadNotification(String path, double progress) {
//   this.service.value.sendData({"percentage": "$progress %"});
// }
//
// void start() {
//   WidgetsFlutterBinding.ensureInitialized();
//   //if (Platform.isIOS) FlutterBackgroundServiceIOS.registerWith();
//   if (Platform.isAndroid) FlutterBackgroundServiceAndroid.registerWith();
//
//   service.value = FlutterBackgroundService();
//   service.value.onDataReceived.listen((event) {
//     if (event["action"] == "setAsForeground") {
//       service.value.setAsForegroundService();
//       return;
//     }
//
//     if (event["action"] == "setAsBackground") {
//       service.value.setAsBackgroundService();
//     }
//
//     if (event["action"] == "stopService") {
//       service.value.stopService();
//     }
//   });
//
//   // bring to foreground
//   service.value.setAsForegroundService();
//   this.service.value.setNotificationInfo(
//         title: Strings.appName,
//         content: "download percentage",
//       );
// }

// Future<void> generateExampleDocument(
//     AttendanceData attendanceData, String fileName) async {
//   String path;
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.storage,
//   ].request();
//
//   // if (attendanceData.data.isNotEmpty) {
//   //   List<List<dynamic>> rows = [];
//   //
//   //   List<dynamic> row = [];
//   //
//   //   row.add("Sr No");
//   //   row.add("date");
//   //   row.add("Emp Id");
//   //   row.add("Name");
//   //   row.add("InTime");
//   //   row.add("OutTime");
//   //   row.add("WHours");
//   //   rows.add(row);
//   //
//   //   for (int i = 0; i < attendanceData.data.length; i++) {
//   //     List<dynamic> row = [];
//   //
//   //     row.add(i + 1);
//   //     row.add(attendanceData.data[i].cDate);
//   //     row.add(attendanceData.data[i].empId);
//   //     row.add(attendanceData.data[i].userName);
//   //     row.add(attendanceData.data[i].inTime);
//   //     row.add(attendanceData.data[i].outTime);
//   //     row.add(getTimeDifferenceString(
//   //         attendanceData.data[i].inTime, attendanceData.data[i].outTime));
//   //     rows.add(row);
//   //   }
//   //
//   //   String csv = const ListToCsvConverter().convert(rows);
//   //
//   //   path = await ExternalPath.getExternalStoragePublicDirectory(
//   //       ExternalPath.DIRECTORY_DOWNLOADS);
//   //   print("dir $path");
//   //   String file = path;
//   //
//   //   File f = File(file +
//   //       "/${fileName}_${DateFormat("yyyy-dd-M--HH-mm-ss").format(DateTime.now())}.csv");
//   //   if (!f.existsSync()) {
//   //     f.createSync();
//   //   }
//   //   Timer.periodic(Duration(microseconds: 1), (timer) async {
//   //     String fileString = await f.readAsString();
//   //     double percentage = ((fileString.length / csv.length) * 100);
//   //     if (percentage < 0.99) {
//   //       localnotification.showLocal(Strings.downloading, "$percentage",
//   //           payloadMsg: {"path": f.path});
//   //     } else {
//   //       localnotification.showLocal(Strings.downloading, "100%",
//   //           payloadMsg: {"path": f.path});
//   //       timer.cancel();
//   //     }
//   //   });
//   //   await f.writeAsString(csv);
//   //   Common.toast(Strings.downloaded_successfully);
//   // } else {
//   //   Common.toast(Strings.noRecordsFound);
//   // }
// }

// Future<List<Data>> getEmployeeDropDown({String fDate, String tDate}) async {
//   List<Data> newList = [];
//   try {
//     bool isConnected = await hasNetwork();
//
//     if (isConnected) {
//       Map<String, dynamic> body = {};
//       body['fdate'] = fDate == null
//           ? DateFormat("dd-MM-yyyy")
//               .format(DateTime.now().subtract(Duration(days: 15)))
//           : fDate;
//       body['tdate'] = tDate == null
//           ? DateFormat("dd-MM-yyyy")
//               .format(DateTime.now().add(Duration(days: 15)))
//           : tDate;
//       //todo
//       AttendanceData attendanceData =
//           await apiService.getAttendanceData(body);
//
//       attendanceData.data.forEach((element) {
//         DateTime fromDateTime, toDateTime, elementDate;
//         fromDateTime = DateTimeFormatter.displayYYYYMMDD.parse(body['fdate']);
//         toDateTime = DateTimeFormatter.displayYYYYMMDD.parse(body['tdate']);
//         elementDate = DateTimeFormatter.displayYYYYMMDD.parse(element.cDate);
//         if (elementDate.isBetween(fromDateTime, toDateTime)) {
//           if (newList.length > 1) {
//             int length = newList
//                 .where(
//                     (newElement) => newElement.userName == element.userName)
//                 .length;
//             if (length == 0) newList.add(element);
//           } else if (newList.length == 1) {
//             if (newList.first.userName != element.userName) {
//               newList.add(element);
//             }
//           } else {
//             newList.add(element);
//           }
//         }
//       });
//
//       newList.sort((a, b) => (a.empId != null && b.empId != null)
//           ? a.empId.compareTo(b.empId)
//           : 1);
//
//       employeeList.value = newList;
//       return newList;
//     } else {
//       Common.toast(Strings.noInternetMsg);
//     }
//   } catch (ex) {
//     print("controllers/report_controller=${ex.toString()}");
//     return newList;
//   }
// }

// Future<void> madeDropDownList(List<emp.Employee> newList, int index) async {
//   try {
//     List<emp.Employee> distinctPais = [];
//     newList.forEach((element) {
//       DropDownModal dropDownModal =
//           DropDownModal(name: element.employee, index: element.empId);
//       distinctPais.add(element);
//       dropDownEmployeeList.add(DropdownMenuItem(
//           child: CustomText(
//             text: dropDownModal.name == null ? "" : dropDownModal.name,
//           ),
//           value: dropDownModal));
//     });
//   } catch (ex) {
//     Get.defaultDialog(title: Strings.error, middleText: ex.toString());
//   }
// }

// void madeDropDownList(List<Data> newList) {
//   try {
//     List<Data> distinctPais = [];
//     newList.forEach((element) {
//       DropDownModal dropDownModal =
//           DropDownModal(name: element.userName, index: element.empId);
//       distinctPais.add(element);
//       dropDownEmployeeList.add(DropdownMenuItem(
//           child: CustomText(
//             text: dropDownModal.name == null ? "" : dropDownModal.name,
//           ),
//           value: dropDownModal));
//     });
//   } catch (ex) {
//     Get.defaultDialog(title: Strings.error, middleText: ex.toString());
//   }
// }

// CalenderReportModel empList = CalenderReportModel.fromJson(response);
// print("HII");
// List<CalenderReportModel> data = empList.data ?? [];
// print("data :: ${data}");
// for (int i = 0; i < data.length; i++) {
//   DropDownModal dropDownModal =
//   DropDownModal(name: data[i].data.employee[i].employee, index: data[i].data.employee[i].empId);
//   dropDownEmployeeList.add(DropdownMenuItem(
//     value: dropDownModal,
//     child: CustomText(text: dropDownModal.name),
//   ));
// }
// selectedEmployee = dropDownEmployeeList.first.value as Rx<DropDownModal>;
// print("select Emp DropDown :: $selectedEmployee");

//   dropDownEmployeeList.clear();
//  print("length :: ${response.data.employee.length}");
// for (int i = 0; i < response.data.employee.length; i++) {
//   print("length :: ${response.data.employee.length}");
//   DropDownModal dropDownModal = DropDownModal(
//       name: response.data.employee[i].employee,
//       index: response.data.employee[i].empId);
//   dropDownEmployeeList.add(DropdownMenuItem(
//     value: dropDownModal,
//     child: CustomText(text: dropDownModal.name),
//   ));
// }
//   selectedEmployee.value ;
//print("selectedEmployee :: ${selectedEmployee.value}");

// if (attendanceData.value != null) {
//   if (attendanceData.value.data != null) {
//     if (attendanceData.value.data.length > 0) {
//       attendanceData.value.data.sort((a, b) {
//         return a.empId != null && b.empId != null
//             ? a.empId.compareTo(b.empId)
//             : 1;
//       });
//     }
//   }
// }

// if (attendanceData.value != null) {
//   if (attendanceData.value.data != null) {
//     if (attendanceData.value.data.length > 0) {
//       attendanceData.value.data.sort((a, b) {
//         return a.empId != null && b.empId != null
//             ? a.empId.compareTo(b.empId)
//             : 1;
//       });
//     }
//   }
// }
//  mAttendanceDataList.data = list.map((e) => InData.fromJson(e)).toList();
// mAttendanceData.success = true;
// attendanceData.value = mAttendanceData;

//  mAttendanceDataList.data = list.map((e) => InData.fromJson(e)).toList();
// mAttendanceData.success = true;
// attendanceData.value = mAttendanceData;

}

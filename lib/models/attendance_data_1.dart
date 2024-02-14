import 'package:geo_attendance_system/models/Data.dart';
import 'package:get/get.dart';

class AttendanceDataModel {
  final bool success;
  final String message;
  final List<Data> data;

  AttendanceDataModel({
    this.success,
    this.message,
    this.data,
  });

  AttendanceDataModel.fromJson(Map<String, dynamic> json)
      : success = json['success'] as bool,
        message = json['message'] as String,
        data = (json['data'] as List).length > 0
            ? (json['data'] as List)
                ?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>))
                ?.toList()
            : [];

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((e) => e.toJson())?.toList()
      };
}

class Data {
  final int id;
  final int empId;
  final String userName;
  final String type;
  final String date;
  final String time;
  final dynamic location;
  final String imagePath;
  final int acceptance;
  final int isMannualApprove;
  final String createdAt;
  final String updatedAt;

  Data({
    this.id,
    this.empId,
    this.userName,
    this.type,
    this.date,
    this.time,
    this.location,
    this.imagePath,
    this.acceptance,
    this.isMannualApprove,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        empId = json['emp_id'] as int,
        userName = json['userName'] as String,
        type = json['type'] as String,
        date = json['date'] as String,
        time = json['time'] as String,
        location = json['location'],
        imagePath = json['image_path'] as String,
        acceptance = json['acceptance'] as int,
        isMannualApprove = json['is_mannual_approve'] as int,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'emp_id': empId,
        'userName': userName,
        'type': type,
        'date': date,
        'time': time,
        'location': location,
        'image_path': imagePath,
        'acceptance': acceptance,
        'is_mannual_approve': isMannualApprove,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}

// class AttendanceData {
//   int id;
//   int empId;
//   String cDate;
//   String inTime;
//   Null outTime;
//   String inLocation;
//   String outLocation;
//   String inImagePath;
//   String outImagePath;
//   int acceptance;
//
//   AttendanceData(
//       {this.id,
//         this.empId,
//         this.cDate,
//         this.inTime,
//         this.outTime,
//         this.inLocation,
//         this.outLocation,
//         this.inImagePath,
//         this.outImagePath,
//         this.acceptance});
//
//   AttendanceData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     empId = json['emp_id'];
//     cDate = json['c_date'];
//     inTime = json['inTime'];
//     outTime = json['OutTime'];
//     inLocation = json['inLocation'];
//     outLocation = json['outLocation'];
//     inImagePath = json['in_image_path'];
//     outImagePath = json['out_image_path'];
//     acceptance = json['acceptance'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['emp_id'] = this.empId;
//     data['c_date'] = this.cDate;
//     data['inTime'] = this.inTime;
//     data['OutTime'] = this.outTime;
//     data['inLocation'] = this.inLocation;
//     data['outLocation'] = this.outLocation;
//     data['in_image_path'] = this.inImagePath;
//     data['out_image_path'] = this.outImagePath;
//     data['acceptance'] = this.acceptance;
//     return data;
//   }
// }

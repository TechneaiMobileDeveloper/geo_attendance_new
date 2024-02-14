import 'Data.dart';

class AttendanceData {
  AttendanceData({
    this.success,
    this.message,
    this.data,
  });

  AttendanceData.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  bool success;
  String message;
  Data data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data.toJson();
    }
    return map;
  }
}

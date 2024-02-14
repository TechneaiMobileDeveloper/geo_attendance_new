class CalenderReportModel {
  final int status;
  final String message;
  final Data data;

  CalenderReportModel({
    this.status,
    this.message,
    this.data,
  });

  CalenderReportModel.fromJson(Map<String, dynamic> json)
      : status = json['status'] as int,
        message = json['message'] as String,
        data = (json['data'] as Map<String,dynamic>) != null ? Data.fromJson(json['data'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'status' : status,
    'message' : message,
    'data' : data?.toJson()
  };
}

class Data {
  final List<Attendance> attendance;
  final int presentDays;
  final int absentDays;
  final int halfDay;
  final String total;
  final List<Employee> employee;

  Data({
    this.attendance,
    this.presentDays,
    this.absentDays,
    this.halfDay,
    this.total,
    this.employee,
  });

  Data.fromJson(Map<String, dynamic> json)
      : attendance = (json['attendance'] as List)?.map((dynamic e) => Attendance.fromJson(e as Map<String,dynamic>))?.toList(),
        presentDays = json['present_days'] as int,
        absentDays = json['absent_days'] as int,
        halfDay = json['half_day'] as int,
        total = json['total'] as String,
        employee = (json['employee'] as List)?.map((dynamic e) => Employee.fromJson(e as Map<String,dynamic>))?.toList();

  Map<String, dynamic> toJson() => {
    'attendance' : attendance?.map((e) => e.toJson())?.toList(),
    'present_days' : presentDays,
    'absent_days' : absentDays,
    'half_day' : halfDay,
    'total' : total,
    'employee' : employee?.map((e) => e.toJson())?.toList()
  };
}

class Attendance {
  final String date;
  final dynamic finalFirstInTime;
  final dynamic finalLastOutTime;
  final String isLate;
  final String attendanceStatus;

  Attendance({
    this.date,
    this.finalFirstInTime,
    this.finalLastOutTime,
    this.isLate,
    this.attendanceStatus,
  });

  Attendance.fromJson(Map<String, dynamic> json)
      : date = json['date'] as String,
        finalFirstInTime = json['final_first_in_time'],
        finalLastOutTime = json['final_last_out_time'],
        isLate = json['is_late'] as String,
        attendanceStatus = json['attendance_status'] as String;

  Map<String, dynamic> toJson() => {
    'date' : date,
    'final_first_in_time' : finalFirstInTime,
    'final_last_out_time' : finalLastOutTime,
    'is_late' : isLate,
    'attendance_status' : attendanceStatus
  };
}

class Employee {
  final int empId;
  final String employee;

  Employee({
    this.empId,
    this.employee,
  });

  Employee.fromJson(Map<String, dynamic> json)
      : empId = json['emp_id'] as int,
        employee = json['employee'] as String;

  Map<String, dynamic> toJson() => {
    'emp_id' : empId,
    'employee' : employee
  };
}
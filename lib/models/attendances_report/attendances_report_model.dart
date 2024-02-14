class AttendanceReportModel {
   int status;
   String message;
   List<Data> data;

  AttendanceReportModel({
    this.status,
    this.message,
    this.data,
  });

  AttendanceReportModel.fromJson(Map<String, dynamic> json)
      : status = json['status'] as int,
        message = json['message'] as String,
        data = (json['data'] as List)?.map((dynamic e) => Data.fromJson(e as Map<String,dynamic>))?.toList();

  Map<String, dynamic> toJson() => {
    'status' : status,
    'message' : message,
    'data' : data?.map((e) => e.toJson())?.toList()
  };
}

class Data {
  final String inTime;
  final String outTime;
  final int inIsManual;
  final int outIsManual;
   final String inType;
   final String outType;
  final String date;
  final String inLocation;
  final String outLocation;
  final int empId;
  final dynamic workingHours;
  final String empName;

  Data({
    this.inTime,
    this.outTime,
    this.inIsManual,
    this.outIsManual,
    this.date,
    this.empId,
    this.workingHours,
    this.empName,
    this.inLocation,
    this.outLocation,
    this.inType,
    this.outType
  });

  Data.fromJson(Map<String, dynamic> json)
      : inTime = json['inTime'] as String,
        outTime = json['outTime'] as String,
        inIsManual = json['inIsManual'] as int,
        outIsManual = json['outIsManual'] as int,
        date = json['date'] as String,
        empId = json['emp_id'] as int,
        workingHours = json['workingHours'] as dynamic,
        empName = json['empname'] as String,
        inLocation = json['in_location'] as String,
        outLocation = json['out_location'] as String,
        inType = json['in_type'] as String,
        outType = json['out_type'] as String;


  Map<String, dynamic> toJson() => {
    'inTime' : inTime,
    'outTime' : outTime,
    'inIsManual' : inIsManual,
    'outIsManual' : outIsManual,
    'date' : date,
    'emp_id' : empId,
    'workingHours' : workingHours,
    'empName' : empName,
    'in_location' : inLocation,
    'out_location' : outLocation,
    'in_type' : inType,
    'out_type' : outType
  };
}
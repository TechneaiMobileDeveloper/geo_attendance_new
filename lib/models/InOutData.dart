class InOutData {
 int id;
  int empId;
  String cDate;
  String inTime;
  String outTime;
  String inLocation;
  String outLocation;
  String inImagePath;
  String outImagePath;
  int acceptance;
  String userName;
  int isManualApprove;

  InOutData(
      {this.id,
        this.empId,
        this.cDate,
        this.inTime,
        this.outTime,
        this.inLocation,
        this.outLocation,
        this.inImagePath,
        this.outImagePath,
        this.acceptance,
        this.userName,
        this.isManualApprove});

  InOutData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    empId = json['emp_id'];
    cDate = json['c_date'];
    inTime = json['inTime'];
    outTime = json['OutTime'];
    inLocation = json['inLocation'];
    outLocation = json['outLocation'];
    inImagePath = json['in_image_path'];
    outImagePath = json['out_image_path'];
    acceptance = json['acceptance'];
    userName = json['userName'];
    isManualApprove = json['is_manual_approve'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['emp_id'] = this.empId;
    data['c_date'] = this.cDate;
    data['inTime'] = this.inTime;
    data['OutTime'] = this.outTime;
    data['inLocation'] = this.inLocation;
    data['outLocation'] = this.outLocation;
    data['in_image_path'] = this.inImagePath;
    data['out_image_path'] = this.outImagePath;
    data['acceptance'] = this.acceptance;
    data['userName'] = this.userName;
    return data;
  }
}
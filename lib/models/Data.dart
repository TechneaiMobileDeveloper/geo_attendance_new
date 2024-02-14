import 'InData.dart';
import 'OutData.dart';

class Data {
  Data({
    this.inData,
    this.outData,
  });

  Data.fromJson(dynamic json) {
    if (json['in_data'] != null) {
      inData = [];
      json['in_data'].forEach((v) {
        inData.add(InData.fromJson(v));
      });
    }
    if (json['out_data'] != null) {
      outData = [];
      json['out_data'].forEach((v) {
        outData.add(InData.fromJson(v));
      });
    }
  }

  List<InData> inData;
  List<InData> outData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (inData != null) {
      map['in_data'] = inData.map((v) => v.toJson()).toList();
    }
    if (outData != null) {
      map['out_data'] = outData.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

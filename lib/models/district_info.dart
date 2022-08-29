// To parse this JSON data, do
//
//     final districtInfo = districtInfoFromMap(jsonString);

import 'dart:convert';

DistrictInfo districtInfoFromMap(String str) =>
    DistrictInfo.fromMap(json.decode(str));

String districtInfoToMap(DistrictInfo data) => json.encode(data.toMap());

class DistrictInfo {
  DistrictInfo({
    required this.canGrow,
    required this.canNotGrow,
  });

  final List<String> canGrow;
  final List<String> canNotGrow;

  factory DistrictInfo.fromMap(Map<String, dynamic> json) => DistrictInfo(
        canGrow: List<String>.from(json["can grow"].map((x) => x)),
        canNotGrow: List<String>.from(json["can not grow"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "can grow": List<dynamic>.from(canGrow.map((x) => x)),
        "can not grow": List<dynamic>.from(canNotGrow.map((x) => x)),
      };
}

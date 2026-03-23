import 'department.dart';

class Service {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? estimatedTime;
  final int departmentId;
  final Department? department;

  Service({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.estimatedTime,
    required this.departmentId,
    this.department,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      estimatedTime: json['estimated_time'],
      departmentId: json['department_id'],
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
    );
  }
}

class Attendance {
  final String? id;
  final String employeeId;
  final String employeeName;
  final String date;
  final String status;

  Attendance({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'date': date,
    'status': status,
  };

  factory Attendance.fromJson(Map<String, dynamic> j) => Attendance(
    id: j['_id']?.toString(),
    employeeId: j['employeeId'] ?? '',
    employeeName: j['employeeName'] ?? '',
    date: j['date'] ?? '',
    status: j['status'] ?? 'absent',
  );
}

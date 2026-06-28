class Leave {
  final String? id;
  final String employeeId;
  final String employeeName;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int totalDays;
  final String reason;
  final String status;

  Leave({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'leaveType': leaveType,
    'fromDate': fromDate,
    'toDate': toDate,
    'totalDays': totalDays,
    'reason': reason,
    'status': status,
  };

  factory Leave.fromJson(Map<String, dynamic> j) => Leave(
    id: j['_id']?.toString(),
    employeeId: j['employeeId'] ?? '',
    employeeName: j['employeeName'] ?? '',
    leaveType: j['leaveType'] ?? '',
    fromDate: j['fromDate'] ?? '',
    toDate: j['toDate'] ?? '',
    totalDays: j['totalDays'] ?? 0,
    reason: j['reason'] ?? '',
    status: j['status'] ?? 'pending',
  );
}

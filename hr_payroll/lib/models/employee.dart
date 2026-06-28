class Employee {
  final String? id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String departmentId;
  final String departmentName;
  final String designation;
  final double basicSalary;
  final String joiningDate;
  final String status;

  Employee({
    this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.departmentName,
    required this.designation,
    required this.basicSalary,
    required this.joiningDate,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'name': name,
    'email': email,
    'phone': phone,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'designation': designation,
    'basicSalary': basicSalary,
    'joiningDate': joiningDate,
    'status': status,
  };

  factory Employee.fromJson(Map<String, dynamic> j) => Employee(
    id: j['_id']?.toString(),
    employeeId: j['employeeId'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'] ?? '',
    departmentId: j['departmentId'] ?? '',
    departmentName: j['departmentName'] ?? '',
    designation: j['designation'] ?? '',
    basicSalary: (j['basicSalary'] ?? 0).toDouble(),
    joiningDate: j['joiningDate'] ?? '',
    status: j['status'] ?? 'active',
  );
}

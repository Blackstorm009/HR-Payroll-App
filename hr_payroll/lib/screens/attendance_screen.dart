import 'package:flutter/material.dart';
import 'package:hr_payroll/services/api_service.dart';
import 'package:hr_payroll/models/attendance.dart';
import 'package:hr_payroll/models/employee.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Employee> _employees = [];
  List<Attendance> _todayAttendance = [];
  bool _loading = true;

  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final empDocs = await ApiService.findAll('employees');
      final attDocs = await ApiService.findAll(
        'attendance',
        params: {'date': _today},
      );
      setState(() {
        _employees = empDocs.map((d) => Employee.fromJson(d)).toList();
        _todayAttendance = attDocs.map((d) => Attendance.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _statusFor(String empId) {
    final found = _todayAttendance.where((a) => a.employeeId == empId);
    return found.isEmpty ? 'not marked' : found.first.status;
  }

  Future<void> _mark(Employee emp, String status) async {
    await ApiService.insertOne('attendance', {
      'employeeId': emp.employeeId,
      'employeeName': emp.name,
      'date': _today,
      'status': status,
    });
    _load();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'half-day':
        return Colors.orange;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance — $_today'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _employees.isEmpty
                  ? const Center(child: Text('No employees found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _employees.length,
                      itemBuilder: (_, i) {
                        final emp = _employees[i];
                        final status = _statusFor(emp.employeeId);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1A73E8),
                              child: Text(
                                emp.name[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(emp.name),
                            subtitle: Text(emp.designation),
                            trailing: PopupMenuButton<String>(
                              onSelected: (s) => _mark(emp, s),
                              child: Chip(
                                label: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _statusColor(status),
                              ),
                              itemBuilder: (_) =>
                                  ['present', 'absent', 'half-day', 'leave']
                                      .map(
                                        (s) => PopupMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

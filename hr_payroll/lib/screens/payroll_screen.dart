import 'package:flutter/material.dart';
import 'package:hr_payroll/services/api_service.dart';
import 'package:hr_payroll/models/employee.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  List<Employee> _employees = [];
  bool _loading = true;

  final String _month = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final docs = await ApiService.findAll('employees');
      setState(() {
        _employees = docs.map((d) => Employee.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _generatePayroll(Employee emp) async {
    final attDocs = await ApiService.findAll(
      'attendance',
      params: {'employeeId': emp.employeeId},
    );

    final presentDays = attDocs
        .where(
          (d) =>
              d['status'] == 'present' &&
              (d['date'] as String).startsWith(_month),
        )
        .length;

    final leaveDocs = await ApiService.findAll(
      'leaves',
      params: {'employeeId': emp.employeeId, 'status': 'approved'},
    );

    final leaveDays = leaveDocs.fold<int>(
      0,
      (sum, d) => sum + ((d['totalDays'] ?? 0) as int),
    );

    const workingDays = 26;
    final perDay = emp.basicSalary / workingDays;
    final absentDays = (workingDays - presentDays - leaveDays).clamp(
      0,
      workingDays,
    );
    final deductions = perDay * absentDays;
    final netSalary = emp.basicSalary - deductions;

    final payrollDoc = {
      'employeeId': emp.employeeId,
      'employeeName': emp.name,
      'month': _month,
      'basicSalary': emp.basicSalary,
      'presentDays': presentDays,
      'leaveDays': leaveDays,
      'deductions': deductions,
      'netSalary': netSalary,
      'generatedAt': DateTime.now().toIso8601String(),
    };

    await ApiService.insertOne('payroll', payrollDoc);
    await ApiService.insertOne('payslips', {
      ...payrollDoc,
      'payslipNo': 'PS-${DateTime.now().millisecondsSinceEpoch}',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payslip generated for ${emp.name} — PKR ${netSalary.toStringAsFixed(0)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payroll — $_month'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? const Center(child: Text('No employees found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _employees.length,
              itemBuilder: (_, i) {
                final emp = _employees[i];
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
                    subtitle: Text(
                      '${emp.designation} · PKR ${emp.basicSalary.toStringAsFixed(0)}',
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Generate'),
                      onPressed: () => _generatePayroll(emp),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

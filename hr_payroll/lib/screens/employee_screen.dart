import 'package:flutter/material.dart';
import 'package:hr_payroll/services/api_service.dart';
import 'package:hr_payroll/models/employee.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});
  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<Employee> _employees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
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

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final desigCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Employee'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Name is required';
                    if (RegExp(r'[0-9]').hasMatch(v))
                      return 'Name cannot contain numbers';
                    if (v.contains(' ')) return 'Name cannot contain spaces';
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    if (!RegExp(
                      r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(v.trim()))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Phone is required';
                    if (v.trim().length > 11)
                      return 'Phone cannot exceed 11 digits';
                    if (v.contains(' ')) return 'Phone cannot contain spaces';
                    return null;
                  },
                ),
                TextFormField(
                  controller: deptCtrl,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextFormField(
                  controller: desigCtrl,
                  decoration: const InputDecoration(labelText: 'Designation'),
                ),
                TextFormField(
                  controller: salaryCtrl,
                  decoration: const InputDecoration(labelText: 'Basic Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Salary is required';
                    final salary = double.tryParse(v.trim());
                    if (salary == null) return 'Enter a valid number';
                    if (salary < 0) return 'Salary cannot be negative';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final emp = Employee(
                employeeId: 'EMP${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                departmentId: 'DEPT001',
                departmentName: deptCtrl.text,
                designation: desigCtrl.text,
                basicSalary: double.tryParse(salaryCtrl.text) ?? 0,
                joiningDate: DateTime.now().toIso8601String().split('T')[0],
              );
              await ApiService.insertOne('employees', emp.toJson());
              if (context.mounted) Navigator.pop(context);
              _loadEmployees();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              child: _employees.isEmpty
                  ? const Center(child: Text('No employees found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _employees.length,
                      itemBuilder: (_, i) {
                        final e = _employees[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1A73E8),
                              child: Text(
                                e.name[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              e.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${e.designation} · ${e.departmentName}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PKR ${e.basicSalary.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await ApiService.deleteOne(
                                      'employees',
                                      e.employeeId,
                                    );
                                    _loadEmployees();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

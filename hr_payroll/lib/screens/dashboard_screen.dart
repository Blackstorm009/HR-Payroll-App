import 'package:flutter/material.dart';
import 'package:hr_payroll/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalEmp = 0;
  int _presentToday = 0;
  int _pendingLeaves = 0;
  double _monthPayroll = 0;
  bool _loading = true;

  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String _month = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final emps = await ApiService.findAll('employees');
      final present = await ApiService.findAll(
        'attendance',
        params: {'date': _today, 'status': 'present'},
      );
      final pending = await ApiService.findAll(
        'leaves',
        params: {'status': 'pending'},
      );
      final payrollDocs = await ApiService.findAll(
        'payroll',
        params: {'month': _month},
      );

      final totalPay = payrollDocs.fold<double>(
        0.0,
        (sum, d) => sum + ((d['netSalary'] ?? 0) as num).toDouble(),
      );

      setState(() {
        _totalEmp = emps.length;
        _presentToday = present.length;
        _pendingLeaves = pending.length;
        _monthPayroll = totalPay;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Dashboard'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard(
                      'Total Employees',
                      '$_totalEmp',
                      Icons.people,
                      Colors.blue,
                    ),
                    _statCard(
                      'Present Today',
                      '$_presentToday',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _statCard(
                      'Pending Leaves',
                      '$_pendingLeaves',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _statCard(
                      'Month Payroll',
                      'PKR ${_monthPayroll.toStringAsFixed(0)}',
                      Icons.payments,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

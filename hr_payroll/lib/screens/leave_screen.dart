import 'package:flutter/material.dart';
import 'package:hr_payroll/services/api_service.dart';
import 'package:hr_payroll/models/leave.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});
  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  List<Leave> _leaves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final docs = await ApiService.findAll('leaves');
      setState(() {
        _leaves = docs.map((d) => Leave.fromJson(d)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Leave leave, String status) async {
    await ApiService.updateOne('leaves', leave.employeeId, {'status': status});
    _load();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leaves.isEmpty
          ? const Center(child: Text('No leave requests found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _leaves.length,
              itemBuilder: (_, i) {
                final l = _leaves[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      l.employeeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${l.leaveType} · ${l.fromDate} → ${l.toDate}\n${l.reason}',
                    ),
                    isThreeLine: true,
                    trailing: l.status == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () => _updateStatus(l, 'approved'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _updateStatus(l, 'rejected'),
                              ),
                            ],
                          )
                        : Chip(
                            label: Text(
                              l.status,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _statusColor(l.status),
                          ),
                  ),
                );
              },
            ),
    );
  }
}

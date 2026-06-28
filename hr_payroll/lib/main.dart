import 'package:flutter/material.dart';
import 'package:hr_payroll/screens/dashboard_screen.dart';
import 'package:hr_payroll/screens/employee_screen.dart';
import 'package:hr_payroll/screens/attendance_screen.dart';
import 'package:hr_payroll/screens/leave_screen.dart';
import 'package:hr_payroll/screens/payroll_screen.dart';

void main() {
  runApp(const HRApp());
}

class HRApp extends StatelessWidget {
  const HRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR & Payroll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),
      const EmployeeScreen(),
      const AttendanceScreen(),
      const LeaveScreen(),
      const PayrollScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.people), label: 'Employees'),
          NavigationDestination(icon: Icon(Icons.today), label: 'Attendance'),
          NavigationDestination(
            icon: Icon(Icons.beach_access),
            label: 'Leaves',
          ),
          NavigationDestination(icon: Icon(Icons.payments), label: 'Payroll'),
        ],
      ),
    );
  }
}

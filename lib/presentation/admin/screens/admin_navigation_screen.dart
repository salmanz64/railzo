import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'manage_trains_screen.dart';
import 'manage_routes_screen.dart';
import 'manage_schedules_screen.dart';
import 'pricing_management_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const ManageTrainsScreen(),
    const ManageRoutesScreen(),
    const ManageSchedulesScreen(),
    const PricingManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
              _buildNavItem(1, Icons.train_outlined, Icons.train, 'Trains'),
              _buildNavItem(2, Icons.route_outlined, Icons.route, 'Routes'),
              _buildNavItem(3, Icons.schedule_outlined, Icons.schedule, 'Schedules'),
              _buildNavItem(4, Icons.attach_money_outlined, Icons.attach_money, 'Pricing'),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(
            context,
            Icons.dashboard,
            'Dashboard',
            'View Statistics',
            () => Navigator.pushNamed(context, '/admin/dashboard'),
            const Color(0xFF66FF00),
          ),
          _buildDashboardCard(
            context,
            Icons.train,
            'Manage Trains',
            'CRUD Operations',
            () => Navigator.pushNamed(context, '/admin/trains'),
            const Color(0xFF66FF00),
          ),
          _buildDashboardCard(
            context,
            Icons.route,
            'Manage Routes',
            'Route Management',
            () => Navigator.pushNamed(context, '/admin/routes'),
            Colors.orange,
          ),
          _buildDashboardCard(
            context,
            Icons.schedule,
            'Schedules',
            'Train Schedules',
            () => Navigator.pushNamed(context, '/admin/schedules'),
            Colors.purple,
          ),
          _buildDashboardCard(
            context,
            Icons.airline_seat_recline_normal,
            'Coach Layout',
            'Seat Arrangement',
            () => Navigator.pushNamed(context, '/admin/coach-layout'),
            Colors.teal,
          ),
          _buildDashboardCard(
            context,
            Icons.attach_money,
            'Pricing',
            'Fare Management',
            () => Navigator.pushNamed(context, '/admin/pricing'),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

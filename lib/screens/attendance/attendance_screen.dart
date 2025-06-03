import 'package:flutter/material.dart';
import '../../widgets/sidebar_drawer.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Asistencia')),
      drawer: const SidebarDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_reg, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Vista Asistencia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrará tu registro de asistencia',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

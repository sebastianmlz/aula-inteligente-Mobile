import 'package:flutter/material.dart';
import '../../widgets/sidebar_drawer.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Materias')),
      drawer: const SidebarDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Vista Materias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrarán tus materias matriculadas',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

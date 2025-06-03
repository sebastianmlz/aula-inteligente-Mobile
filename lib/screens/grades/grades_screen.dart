import 'package:flutter/material.dart';
import '../../widgets/sidebar_drawer.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Calificaciones')),
      drawer: const SidebarDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade, size: 80, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'Vista Calificaciones',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrarán tus calificaciones',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

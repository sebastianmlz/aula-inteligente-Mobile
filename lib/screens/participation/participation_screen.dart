import 'package:flutter/material.dart';
import '../../widgets/sidebar_drawer.dart';

class ParticipationScreen extends StatelessWidget {
  const ParticipationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Participaciones')),
      drawer: const SidebarDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'Vista Participaciones',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí se mostrará tu registro de participaciones',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

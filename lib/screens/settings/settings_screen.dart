import 'package:flutter/material.dart';
import '../../../widgets/sidebar_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      drawer: const SidebarDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Vista Configuración',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí podrás ajustar la configuración de la aplicación',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

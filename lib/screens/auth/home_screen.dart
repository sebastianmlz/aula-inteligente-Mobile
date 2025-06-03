import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sidebar_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula Inteligente'),
        actions: [
          // Añadir un botón de logout en la barra de aplicación
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      // Mantener el drawer
      drawer: const SidebarDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${user?.firstName ?? 'Estudiante'}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona una opción del menú',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'Desliza desde la izquierda o\npresiona el botón de menú',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            // Botón de logout en la pantalla principal
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Método simplificado para cerrar sesión
  void _logout(BuildContext context) {
    // Mostrar diálogo de confirmación
    showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Sí, cerrar sesión'),
              ),
            ],
          ),
    ).then((confirm) {
      // Si el usuario confirmó, proceder con el cierre de sesión
      if (confirm == true) {
        _performLogout(context);
      }
    });
  }

  // Método para ejecutar el logout
  void _performLogout(BuildContext context) {
    // Capturar una referencia estática al contexto actual
    final currentContext = context;

    // Mostrar indicador de carga
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder:
          (BuildContext loadingContext) =>
              const Center(child: CircularProgressIndicator()),
    );

    // Realizar el logout de manera asíncrona
    Provider.of<AuthProvider>(currentContext, listen: false).logout().then(
      (success) {
        // Verificar si el widget sigue montado
        if (currentContext.mounted) {
          // Cerrar el diálogo de carga
          Navigator.of(currentContext).pop();

          if (success) {
            // Navegar a login y eliminar todas las rutas anteriores
            Navigator.of(
              currentContext,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(currentContext).showSnackBar(
              const SnackBar(
                content: Text('Error al cerrar sesión'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onError: (e) {
        // Manejar cualquier error
        if (currentContext.mounted) {
          Navigator.of(currentContext).pop(); // Cerrar diálogo de carga
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      },
    );
  }
}

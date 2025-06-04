import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/logger_util.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Encabezado del drawer
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              accountName: Text(
                "Bienvenido, ${user?.firstName ?? 'Estudiante'}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(user),
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            // Añadir opción de Home al inicio
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
            ),

            const Divider(), // Separador visual
            // Opciones del menú
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Materias'),
              onTap: () {
                // Primero cerramos el drawer
                Navigator.pop(context);
                // Luego navegamos
                Navigator.pushNamed(context, '/subjects');
              },
            ),

            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: const Text('Asistencias'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/attendance');
              },
            ),

            // Calificaciones
            ListTile(
              leading: const Icon(Icons.grading),
              title: const Text('Calificaciones'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/grades');
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Participaciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/participation');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),

            const Spacer(),

            // Opción para cerrar sesión en la parte inferior con enfoque simplificado
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  // Primero cerramos el drawer
                  Navigator.pop(context);
                  // Luego mostramos el diálogo de confirmación
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método simplificado para logout
  void _logout(BuildContext context) {
    // Capturar contexto actual
    final currentContext = context;

    showDialog<bool>(
      context: currentContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sí, cerrar sesión'),
              ),
            ],
          ),
    ).then((confirm) {
      if (confirm == true) {
        _performLogout(currentContext);
      }
    });
  }

  // Método para ejecutar el logout
  void _performLogout(BuildContext context) {
    // Primero cerramos el drawer para evitar problemas de contexto
    Navigator.pop(context);

    // Ahora trabajamos con el contexto de la pantalla principal
    final currentContext = context;

    // Mostrar indicador de carga
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder:
          (loadingContext) => const Center(child: CircularProgressIndicator()),
    );

    // Realizar logout de manera asíncrona
    Provider.of<AuthProvider>(currentContext, listen: false).logout().then(
      (success) {
        // Verificar si el widget sigue montado
        if (currentContext.mounted) {
          // Cerrar diálogo de carga
          Navigator.of(currentContext).pop();

          if (success) {
            // Navegar directamente sin usar microtask
            Navigator.of(
              currentContext,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
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
        if (currentContext.mounted) {
          Navigator.of(currentContext).pop(); // Cerrar diálogo de carga
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  // Método para obtener las iniciales
  String _getInitials(dynamic user) {
    final firstName = user?.firstName;
    if (firstName != null && firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }
    return "A";
  }
}

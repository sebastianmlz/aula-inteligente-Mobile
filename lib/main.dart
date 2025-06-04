import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/participation_provider.dart'; // Añadir esta línea
import 'providers/grade_provider.dart'; // Importar el proveedor de calificaciones
import 'screens/auth/login_screen.dart';
import 'screens/auth/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subjects/subjects_screen.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/grades/grade_screen.dart';
import 'screens/participation/participation_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'utils/logger_util.dart'; // Añadir esta línea

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AcademicProvider()),
        ChangeNotifierProvider(
          create: (context) => AttendanceProvider(),
        ), // Añadir esta línea
        ChangeNotifierProvider(
          create: (context) => ParticipationProvider(),
        ), // Añadir esta línea
        ChangeNotifierProvider(
          create: (_) => GradeProvider(),
        ), // Agregar esto a la lista de providers
      ],
      child: MaterialApp(
        title: 'Aula Inteligente',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthCheckScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/subjects': (context) => const SubjectsScreen(),
          '/attendance': (context) => const AttendanceScreen(),
          '/grades': (context) => const GradeScreen(),
          '/participation': (context) => const ParticipationScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Añadir log para depurar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoggerUtil.instance.i(
        "AuthCheckScreen - isAuthenticated: ${authProvider.isAuthenticated}",
      );
    });

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      // Forzar recreación del widget con una clave única
      return const LoginScreen(key: ValueKey('login_after_logout'));
    }
  }
}

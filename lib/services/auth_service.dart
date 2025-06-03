import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/user_model.dart';
import '../utils/logger_util.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _logger = LoggerUtil.instance;

  // Método para iniciar sesión
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _logger.i('Iniciando login para: $email');

      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}${ApiEndpoints.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _logger.d('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        await _storage.write(key: 'user_data', value: jsonEncode(data));

        if (data['student_id'] != null) {
          await _storage.write(key: 'student_id', value: data['student_id']);
        }

        _logger.i('Login exitoso para: $email');

        return {'success': true, 'user': User.fromJson(data)};
      } else {
        final data = jsonDecode(response.body);
        _logger.w(
          'Error de autenticación: ${data['detail'] ?? 'Error desconocido'}',
        );

        return {
          'success': false,
          'message': data['detail'] ?? 'Error de autenticación',
        };
      }
    } catch (e) {
      _logger.e(
        'Error durante el login',
        error: e,
        stackTrace: StackTrace.current,
      );

      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Método para cerrar sesión
  Future<Map<String, dynamic>> logout() async {
    try {
      _logger.i('Iniciando cierre de sesión');

      // Asegúrate de borrar TODOS los datos almacenados
      await _storage.deleteAll(); // Si tu biblioteca lo soporta
      // O borra cada clave individualmente:
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_data');
      await _storage.delete(key: 'student_id');

      // Registra el éxito para depuración
      _logger.i("Todos los datos fueron borrados correctamente");

      return {'success': true};
    } catch (e) {
      _logger.e(
        'Error durante el cierre de sesión',
        error: e,
        stackTrace: StackTrace.current,
      );
      return {'success': false, 'message': 'Error al cerrar sesión: $e'};
    }
  }

  // Método para verificar si hay una sesión activa
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      final token = await _storage.read(key: 'access_token');

      if (userData != null && token != null) {
        _logger.d('Sesión activa encontrada');
        return User.fromJson(jsonDecode(userData));
      }
      _logger.d('No se encontró sesión activa');
      return null;
    } catch (e) {
      _logger.e('Error al obtener usuario actual', error: e);
      return null;
    }
  }

  // Método para obtener el token de acceso
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Método para obtener el ID del estudiante
  Future<String?> getStudentId() async {
    return await _storage.read(key: 'student_id');
  }
}

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/logger_util.dart'; // Añade esta línea

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _logger = LoggerUtil.instance; // Añade esta línea
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _studentId;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get errorMessage => _errorMessage;
  String? get studentId => _studentId;

  // Constructor que intenta recuperar la sesión del usuario
  AuthProvider() {
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.getCurrentUser();
    _studentId = await _authService.getStudentId();

    _isLoading = false;
    notifyListeners();
  }

  // Método para iniciar sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = result['user'];
        _studentId = _user?.studentId;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para cerrar sesión
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    // Para depuración (mejor usar _logger en lugar de print)
    _logger.i("Iniciando proceso de logout...");

    try {
      // Llamar al servicio de logout
      final result = await _authService.logout();

      // Verificar si el logout fue exitoso según la respuesta del servicio
      final success = result['success'] ?? true;

      // Para depuración
      _logger.i("Resultado del servicio de logout: $result");

      // Independiente del resultado, reseteamos los datos locales
      _user = null;
      _studentId = null;
      _errorMessage = '';
      _isLoading = false;

      // Para depuración
      _logger.i("Datos locales reseteados");

      notifyListeners();

      // Para depuración
      _logger.i("Notificación enviada a oyentes");

      return success;
    } catch (e) {
      _logger.e("Error en logout: $e");
      _errorMessage = 'Error al cerrar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return _user?.hasRole(role) ?? false;
  }

  // Verificar si el usuario es estudiante
  bool get isStudent => hasRole('Student');
}

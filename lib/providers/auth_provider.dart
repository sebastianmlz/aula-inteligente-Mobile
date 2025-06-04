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

    _logger.i("Iniciando proceso de logout...");

    try {
      // Llamar al servicio de logout
      final result = await _authService.logout();
      final success = result['success'] ?? true;

      _logger.i("Resultado del servicio de logout: $result");

      // LIMPIEZA COMPLETA - Reset todos los datos del provider
      _resetProviderState();

      return success;
    } catch (e) {
      _logger.e("Error en logout: $e");
      _errorMessage = 'Error al cerrar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para resetear completamente el estado del provider
  void _resetProviderState() {
    _user = null;
    _studentId = null;
    _errorMessage = '';
    _isLoading = false;

    _logger.i("Datos del provider reseteados completamente");
    notifyListeners();

    // Esperar un momento para que la notificación surta efecto
    Future.delayed(const Duration(milliseconds: 100), () {
      _logger.i(
        "Verificación post-reset: user=${_user == null ? 'null' : 'not null'}",
      );
    });
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

  // Añadir este getter para obtener el token
  Future<String?> get token async => await _authService.getAccessToken();
}

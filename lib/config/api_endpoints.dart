class ApiEndpoints {
  // Endpoints de autenticación
  static const String login = 'auth/login/';
  static const String logout =
      'auth/logout/'; // Lo mantenemos por ahora, pero lo modificaremos en el servicio

  // Endpoints para estudiantes
  static const String attendance = 'student/attendance/';
  static const String grades = 'student/grades/';
  static const String participation = 'student/participation/';
  static const String subjects = 'student/subjects/';
}

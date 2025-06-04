class ApiEndpoints {
  // Endpoints existentes
  static const String login = 'auth/login/';
  static const String logout = 'auth/logout/';
  static const String validateToken = 'auth/validate-token/';
  static const String refreshToken = 'auth/refresh-token/';

  // Endpoints académicos
  static const String subjects = 'academic/subjects/';
  static const String courses = 'academic/courses/';
  static const String attendances = 'academic/attendances/';

  // Nuevo endpoint de participaciones
  static const String participations = 'academic/participations/';

  // Agregar este endpoint
  static const String grades = 'academic/grades/';
}

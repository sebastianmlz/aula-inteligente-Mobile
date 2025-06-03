class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? address;
  final String dateOfBirth;
  final bool isActive;
  final List<int> groups;
  final List<String> groupNames;
  final String createdAt;
  final String updatedAt;
  final List<String> roles;
  final bool hasStudentProfile;
  final bool hasTeacherProfile;
  final String? studentId;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.address,
    required this.dateOfBirth,
    required this.isActive,
    required this.groups,
    required this.groupNames,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    required this.hasStudentProfile,
    required this.hasTeacherProfile,
    this.studentId,
  });

  // Obtener el nombre completo del usuario
  String get fullName => '$firstName $lastName';

  // Verificar si tiene un rol específico
  bool hasRole(String role) => roles.contains(role);

  factory User.fromJson(Map<String, dynamic> json) {
    // Extraer datos del usuario del JSON
    var userData = json.containsKey('user') ? json['user'] : json;

    return User(
      id: userData['id'],
      email: userData['email'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      phoneNumber: userData['phone_number'],
      address: userData['address'],
      dateOfBirth: userData['date_of_birth'],
      isActive: userData['is_active'],
      groups: List<int>.from(userData['groups']),
      groupNames: List<String>.from(userData['group_names']),
      createdAt: userData['created_at'],
      updatedAt: userData['updated_at'],
      roles: json.containsKey('roles') ? List<String>.from(json['roles']) : [],
      hasStudentProfile: json['has_student_profile'] ?? false,
      hasTeacherProfile: json['has_teacher_profile'] ?? false,
      studentId: json['student_id'],
    );
  }
}

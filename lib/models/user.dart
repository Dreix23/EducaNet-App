class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String school;
  final List<String> codigoQR;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.school,
    required this.codigoQR,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      school: data['school'] ?? '',
      codigoQR: List<String>.from(data['codigoQR'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'school': school,
      'codigoQR': codigoQR,
    };
  }
}

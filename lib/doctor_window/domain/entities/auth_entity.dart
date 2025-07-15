class AuthCredentials {
  final String login;
  final String password;

  const AuthCredentials({
    required this.login,
    required this.password,
  });
}

class Doctor {
  final String id;
  final String name;
  final String specialization;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
  });
}
import '../../domain/entities/auth_entity.dart';

class AuthLocalDataSource {
  Future<Doctor> signIn(AuthCredentials credentials) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (credentials.login == 'doctor' && credentials.password == 'doctor') {
      return const Doctor(
        id: '1',
        name: 'Иванов И.И.',
        specialization: 'Терапевт',
      );
    } else {
      throw Exception('Неверные учетные данные');
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
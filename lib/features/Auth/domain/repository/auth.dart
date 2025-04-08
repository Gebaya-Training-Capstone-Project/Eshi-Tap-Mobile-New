import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String address,
  });

  Future<User> login(String username, String password);

  Future<User> getLoggedInUser();

  Future<void> logout();
}
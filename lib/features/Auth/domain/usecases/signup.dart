import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';

import '../entities/user.dart';


class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<User> call({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    return await repository.register(
      username: username,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );
  }
}
import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';

import '../entities/user.dart';


class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<User> call(String username, String password) async {
    return await repository.login(username, password);
  }
}
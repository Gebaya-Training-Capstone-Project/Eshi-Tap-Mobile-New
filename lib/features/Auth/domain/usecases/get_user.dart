import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';

import '../entities/user.dart';


class GetLoggedInUser {
  final AuthRepository repository;

  GetLoggedInUser(this.repository);

  Future<User> call() async {
    return await repository.getLoggedInUser();
  }
}
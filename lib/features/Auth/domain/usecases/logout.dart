import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';



class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
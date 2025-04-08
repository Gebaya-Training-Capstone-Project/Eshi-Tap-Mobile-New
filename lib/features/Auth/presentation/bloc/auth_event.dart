part of 'auth_bloc.dart';

abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String phone;
  final String address;

  RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);
}

class CheckAuthEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
import 'package:eshi_tap/features/Auth/data/models/user.dart';
import 'package:eshi_tap/features/Auth/data/source/auth_api_service.dart';
import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';

import '../models/signin_req_params.dart';
import '../models/signup_req_params.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, {this.secureStorage = const FlutterSecureStorage()});

  @override
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final userModel = await remoteDataSource.register(SignupReqParams(
      username: username,
      email: email,
      password: password,
      confirmPassword: password,
      phone: phone,
      address: address,
    ));
    return userModel.toEntity();
  }

  @override
  Future<User> login(String username, String password) async {
    final userModel = await remoteDataSource.login(SigninReqParams(
      username: username,
      password: password,
    ));
    await secureStorage.write(key: 'token', value: userModel.token);
    return userModel.toEntity();
  }

  @override
  Future<User> getLoggedInUser() async {
    final token = await secureStorage.read(key: 'token');
    if (token == null) throw Exception('No token found');
    final userModel = await remoteDataSource.getLoggedInUser(token);
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
  }
}
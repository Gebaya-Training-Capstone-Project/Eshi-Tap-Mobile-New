import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Auth/data/models/user.dart';
import '../models/signin_req_params.dart';
import '../models/signup_req_params.dart';


class AuthRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  AuthRemoteDataSource(this.dio);

  Future<UserModel> register(SignupReqParams params) async {
    try {
      final response = await dio.post(
        '$baseUrl/user/create',
        data: params.toJson(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data['data']);
      }
      throw Exception('Registration failed: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<UserModel> login(SigninReqParams params) async {
    try {
      final response = await dio.post(
        '$baseUrl/user/login',
        data: params.toMap(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data['data']);
      }
      throw Exception('Login failed: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<UserModel> getLoggedInUser(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/user/loggedInUser',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data['data']);
      }
      throw Exception('Failed to fetch user: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
}
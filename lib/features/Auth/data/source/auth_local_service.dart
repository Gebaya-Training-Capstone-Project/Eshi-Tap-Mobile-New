import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalService {
  Future<bool> isLoggedIn();
  Future<Either> logout();
  Future<String?> getToken();
  Future<String?> getCustomerId();
  Future<void> saveAuthData(String token, String customerId);
}

class AuthLocalServiceImpl extends AuthLocalService {
  @override
  Future<bool> isLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var customerId = sharedPreferences.getString('customer_id');
    return token != null && customerId != null && token.isNotEmpty && customerId.isNotEmpty;
  }

  @override
  Future<Either> logout() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.remove('token');
      await sharedPreferences.remove('customer_id');
      return const Right(true);
    } catch (e) {
      return Left(e);
    }
  }

  @override
  Future<String?> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('token');
  }

  @override
  Future<String?> getCustomerId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('customer_id');
  }

  @override
  Future<void> saveAuthData(String token, String customerId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('token', token);
    await sharedPreferences.setString('customer_id', customerId);
  }
}
import 'package:eshi_tap/features/Auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String phone;
  final String address;
  final String role;
  final String profile = 'Nebil';
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.address,
    required this.role,
    
    this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      role: map['role'] as String,
      
      token: map['token'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'address': address,
      'role': role,
      'profile': profile,
      'token': token,
    };
  }
}

extension UserXModel on UserModel {
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      phone: phone,
      address: address,
      role: role,
      profile: profile,
      token: token,
    );
  }
}
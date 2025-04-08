class SignupReqParams {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String address;

  SignupReqParams({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'address': address,
    };
  }
}
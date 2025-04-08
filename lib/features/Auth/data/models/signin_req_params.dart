class SigninReqParams {
  final String username; // Changed from email to username
  final String password;

  SigninReqParams({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}
class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String profile;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.profile,
    this.token,
  });
}
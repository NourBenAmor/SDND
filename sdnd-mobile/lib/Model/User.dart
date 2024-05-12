class User {
  final String id;
  final String username;
  final String email;
  final String token;

  User(this.token, {required this.id, required this.username, required this.email});
}

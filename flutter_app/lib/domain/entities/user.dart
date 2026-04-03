class User {
  const User({
    required this.id,
    required this.email,
    this.nickname,
    this.profileImageUrl,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? nickname;
  final String? profileImageUrl;
  final DateTime createdAt;
}

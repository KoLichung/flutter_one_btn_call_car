class User {
  final String id;
  final String nickname;
  final String phone;
  final String? lineId;
  final String loginMethod; // 'phone' or 'line'

  User({
    required this.id,
    required this.nickname,
    required this.phone,
    this.lineId,
    required this.loginMethod,
  });
}


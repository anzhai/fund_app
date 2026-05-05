import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.phone,
    super.email,
    super.avatar,
    required super.hasFundAccount,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      hasFundAccount: json['has_fund_account'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
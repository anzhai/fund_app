import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String phone;
  final String? idCard;
  final String userType;
  final String? riskLevel;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.phone,
    this.idCard,
    this.userType = 'direct_sales',
    this.riskLevel,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
  });

  // 便捷getter：是否有基金账户（已开户且已验证）
  bool get hasFundAccount => isVerified && isActive;
  
  // 便捷getter：用户名（使用手机号脱敏显示）
  String get username {
    if (phone.length >= 7) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  @override
  List<Object?> get props => [id, phone, userType, isVerified];
}
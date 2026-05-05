import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.phone,
    super.idCard,
    super.userType,
    super.riskLevel,
    super.isVerified,
    super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      idCard: json['id_card'] as String?,
      userType: json['user_type'] as String? ?? 'direct_sales',
      riskLevel: json['risk_level'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'id_card': idCard,
      'user_type': userType,
      'risk_level': riskLevel,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

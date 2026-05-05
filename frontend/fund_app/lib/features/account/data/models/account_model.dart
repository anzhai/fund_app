import '../../domain/entities/account.dart';

class BankCardModel extends BankCard {
  const BankCardModel({
    required super.id,
    required super.userId,
    required super.bankName,
    required super.bankCode,
    required super.cardNo,
    required super.cardType,
    required super.isDefault,
    required super.createdAt,
  });

  factory BankCardModel.fromJson(Map<String, dynamic> json) {
    return BankCardModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bankName: json['bank_name'] as String,
      bankCode: json['bank_code'] as String,
      cardNo: json['card_no'] as String,
      cardType: json['card_type'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class RiskAssessmentModel extends RiskAssessment {
  const RiskAssessmentModel({
    required super.id,
    required super.userId,
    required super.level,
    required super.assessedAt,
    required super.expiresAt,
  });

  factory RiskAssessmentModel.fromJson(Map<String, dynamic> json) {
    return RiskAssessmentModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      level: json['level'] as String,
      assessedAt: DateTime.parse(json['assessed_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

class AccountOpenModel extends AccountOpen {
  const AccountOpenModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.status,
    super.failReason,
    required super.createdAt,
    super.processedAt,
  });

  factory AccountOpenModel.fromJson(Map<String, dynamic> json) {
    return AccountOpenModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      failReason: json['fail_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
    );
  }
}
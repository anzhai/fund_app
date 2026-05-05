import 'package:equatable/equatable.dart';

/// Bank Card Entity
class BankCard extends Equatable {
  final int id;
  final int userId;
  final String bankName;
  final String bankCode;
  final String cardNo;
  final String cardType;
  final bool isDefault;
  final DateTime createdAt;

  const BankCard({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.bankCode,
    required this.cardNo,
    required this.cardType,
    required this.isDefault,
    required this.createdAt,
  });

  String get maskedCardNo => '**** **** **** ${cardNo.substring(cardNo.length - 4)}';

  @override
  List<Object?> get props => [id, userId, cardNo];
}

/// Risk Assessment Entity
class RiskAssessment extends Equatable {
  final int id;
  final int userId;
  final String level;
  final DateTime assessedAt;
  final DateTime expiresAt;

  const RiskAssessment({
    required this.id,
    required this.userId,
    required this.level,
    required this.assessedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get levelName {
    switch (level) {
      case 'conservative': return '保守型';
      case 'balanced': return '平衡型';
      case 'growth': return '成长型';
      case 'aggressive': return '激进型';
      default: return level;
    }
  }

  @override
  List<Object?> get props => [id, userId, level, assessedAt];
}

/// Account Opening Request
class AccountOpen extends Equatable {
  final int id;
  final int userId;
  final String type;
  final String status;
  final String? failReason;
  final DateTime createdAt;
  final DateTime? processedAt;

  const AccountOpen({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.failReason,
    required this.createdAt,
    this.processedAt,
  });

  @override
  List<Object?> get props => [id, userId, type, status];
}
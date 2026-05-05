import '../../domain/entities/fund.dart';

/// Fund Model - 数据传输对象
class FundModel extends Fund {
  const FundModel({
    required super.id,
    required super.fundCode,
    required super.fundName,
    required super.fundType,
    required super.riskLevel,
    required super.nav,
    required super.accNav,
    required super.minPurchase,
    required super.purchaseFee,
    required super.redeemFee,
    super.managerName,
    super.companyName,
    super.description,
    required super.status,
    super.createdAt,
  });

  factory FundModel.fromJson(Map<String, dynamic> json) {
    return FundModel(
      id: json['id'] as int,
      fundCode: json['fund_code'] as String,
      fundName: json['fund_name'] as String,
      fundType: json['fund_type'] as String,
      riskLevel: json['risk_level'] as String,
      nav: json['nav']?.toString() ?? '0.0000',
      accNav: json['acc_nav']?.toString() ?? '0.0000',
      minPurchase: json['min_purchase']?.toString() ?? '0.00',
      purchaseFee: json['purchase_fee']?.toString() ?? '0.0000',
      redeemFee: json['redeem_fee']?.toString() ?? '0.0000',
      managerName: json['manager_name'] as String?,
      companyName: json['company_name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fund_code': fundCode,
      'fund_name': fundName,
      'fund_type': fundType,
      'risk_level': riskLevel,
      'nav': nav,
      'acc_nav': accNav,
      'min_purchase': minPurchase,
      'purchase_fee': purchaseFee,
      'redeem_fee': redeemFee,
      'manager_name': managerName,
      'company_name': companyName,
      'description': description,
      'status': status,
    };
  }
}

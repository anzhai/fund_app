import 'package:equatable/equatable.dart';

/// Fund Entity - 基金实体
class Fund extends Equatable {
  final int id;
  final String fundCode;
  final String fundName;
  final String fundType;
  final String riskLevel;
  final String nav;
  final String accNav;
  final String minPurchase;
  final String purchaseFee;
  final String redeemFee;
  final String? managerName;
  final String? companyName;
  final String? description;
  final String status;
  final DateTime? createdAt;

  const Fund({
    required this.id,
    required this.fundCode,
    required this.fundName,
    required this.fundType,
    required this.riskLevel,
    required this.nav,
    required this.accNav,
    required this.minPurchase,
    required this.purchaseFee,
    required this.redeemFee,
    this.managerName,
    this.companyName,
    this.description,
    required this.status,
    this.createdAt,
  });

  String get fundTypeName {
    switch (fundType) {
      case 'money_market': return '货币基金';
      case 'stock': return '股票基金';
      case 'hybrid': return '混合基金';
      case 'bond': return '债券基金';
      case 'fof': return 'FOF基金';
      default: return fundType;
    }
  }

  @override
  List<Object?> get props => [id, fundCode, fundName, fundType, riskLevel];
}

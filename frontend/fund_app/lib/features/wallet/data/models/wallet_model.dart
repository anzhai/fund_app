import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.frozenAmount,
    super.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balance: (json['balance'] as num).toDouble(),
      frozenAmount: (json['frozen_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class TradeOrderModel extends TradeOrder {
  const TradeOrderModel({
    required super.id,
    required super.orderNo,
    required super.fundCode,
    required super.fundName,
    required super.type,
    required super.amount,
    required super.shares,
    required super.status,
    required super.createdAt,
  });

  factory TradeOrderModel.fromJson(Map<String, dynamic> json) {
    return TradeOrderModel(
      id: json['id'] as int,
      orderNo: json['order_no'] as String,
      fundCode: json['fund_code'] as String,
      fundName: json['fund_name'] as String? ?? '',
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

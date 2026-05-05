import 'package:equatable/equatable.dart';

/// Wallet Entity
class Wallet extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final double frozenAmount;
  final DateTime? createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.frozenAmount,
    this.createdAt,
  });

  double get availableBalance => balance - frozenAmount;

  @override
  List<Object?> get props => [id, userId, balance, frozenAmount];
}

/// Trade Order Entity
class TradeOrder extends Equatable {
  final int id;
  final String orderNo;
  final String fundCode;
  final String fundName;
  final String type;
  final double amount;
  final double shares;
  final String status;
  final DateTime createdAt;

  const TradeOrder({
    required this.id,
    required this.orderNo,
    required this.fundCode,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.shares,
    required this.status,
    required this.createdAt,
  });

  String get typeName {
    switch (type) {
      case 'purchase': return '购买';
      case 'redeem': return '赎回';
      case 'sip': return '定投';
      default: return type;
    }
  }

  @override
  List<Object?> get props => [id, orderNo, fundCode, type, status];
}

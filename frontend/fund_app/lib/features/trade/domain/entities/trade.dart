import 'package:equatable/equatable.dart';

/// Trade Request Entity - User's buy/sell requests
class TradeRequest extends Equatable {
  final int id;
  final String orderNo;
  final String fundCode;
  final String fundName;
  final String type;
  final double amount;
  final double nav;
  final double shares;
  final String status;
  final String? failReason;
  final DateTime createdAt;
  final DateTime? processedAt;

  const TradeRequest({
    required this.id,
    required this.orderNo,
    required this.fundCode,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.nav,
    required this.shares,
    required this.status,
    this.failReason,
    required this.createdAt,
    this.processedAt,
  });

  bool get isBuy => type == 'buy' || type == 'purchase';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [id, orderNo, fundCode, type, status];
}

/// Fund NAV History
class NavHistory extends Equatable {
  final DateTime date;
  final double nav;
  final double? prevNav;

  const NavHistory({
    required this.date,
    required this.nav,
    this.prevNav,
  });

  double get change {
    if (prevNav == null || prevNav == 0) return 0;
    return (nav - prevNav!) / prevNav!;
  }

  @override
  List<Object?> get props => [date, nav];
}
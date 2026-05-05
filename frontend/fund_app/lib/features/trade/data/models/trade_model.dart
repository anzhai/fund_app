import '../../domain/entities/trade.dart';

class TradeRequestModel extends TradeRequest {
  const TradeRequestModel({
    required super.id,
    required super.orderNo,
    required super.fundCode,
    required super.fundName,
    required super.type,
    required super.amount,
    required super.nav,
    required super.shares,
    required super.status,
    super.failReason,
    required super.createdAt,
    super.processedAt,
  });

  factory TradeRequestModel.fromJson(Map<String, dynamic> json) {
    return TradeRequestModel(
      id: json['id'] as int,
      orderNo: json['order_no'] as String,
      fundCode: json['fund_code'] as String,
      fundName: json['fund_name'] as String? ?? '',
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      failReason: json['fail_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
    );
  }
}

class NavHistoryModel extends NavHistory {
  const NavHistoryModel({
    required super.date,
    required super.nav,
    super.prevNav,
  });

  factory NavHistoryModel.fromJson(Map<String, dynamic> json, {double? prevNav}) {
    return NavHistoryModel(
      date: DateTime.parse(json['date'] as String),
      nav: (json['nav'] as num).toDouble(),
      prevNav: prevNav,
    );
  }
}
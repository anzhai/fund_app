import '../../domain/entities/portfolio.dart';

class PortfolioModel extends Portfolio {
  const PortfolioModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.totalAmount,
    required super.todayProfit,
    required super.totalProfit,
    required super.profitRate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      todayProfit: (json['today_profit'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      profitRate: (json['profit_rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'total_amount': totalAmount,
      'today_profit': todayProfit,
      'total_profit': totalProfit,
      'profit_rate': profitRate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PortfolioFundModel extends PortfolioFund {
  const PortfolioFundModel({
    required super.id,
    required super.portfolioId,
    required super.fundCode,
    required super.fundName,
    required super.shares,
    required super.cost,
    required super.currentNav,
    required super.profit,
    required super.profitRate,
  });

  factory PortfolioFundModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFundModel(
      id: json['id'] as int,
      portfolioId: json['portfolio_id'] as int,
      fundCode: json['fund_code'] as String,
      fundName: json['fund_name'] as String? ?? '',
      shares: (json['shares'] as num).toDouble(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      currentNav: (json['current_nav'] as num).toDouble(),
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      profitRate: (json['profit_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
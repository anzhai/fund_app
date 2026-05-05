import 'package:equatable/equatable.dart';

/// Portfolio Entity - User's fund portfolio
class Portfolio extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final double totalAmount;
  final double todayProfit;
  final double totalProfit;
  final double profitRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Portfolio({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.totalAmount,
    required this.todayProfit,
    required this.totalProfit,
    required this.profitRate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, totalAmount];
}

/// Portfolio Fund - Individual fund holding in a portfolio
class PortfolioFund extends Equatable {
  final int id;
  final int portfolioId;
  final String fundCode;
  final String fundName;
  final double shares;
  final double cost;
  final double currentNav;
  final double profit;
  final double profitRate;

  const PortfolioFund({
    required this.id,
    required this.portfolioId,
    required this.fundCode,
    required this.fundName,
    required this.shares,
    required this.cost,
    required this.currentNav,
    required this.profit,
    required this.profitRate,
  });

  double get marketValue => shares * currentNav;

  @override
  List<Object?> get props => [id, portfolioId, fundCode, shares];
}
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/portfolio.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, List<Portfolio>>> getPortfolios();
  Future<Either<Failure, Portfolio>> getPortfolio(int id);
  Future<Either<Failure, List<PortfolioFund>>> getPortfolioFunds(int portfolioId);
  Future<Either<Failure, Portfolio>> createPortfolio({required String name, String? description});
  Future<Either<Failure, void>> deletePortfolio(int id);
  Future<Either<Failure, PortfolioFund>> addFund({required int portfolioId, required String fundCode, required double amount});
  Future<Either<Failure, void>> removeFund({required int portfolioId, required String fundCode});
}
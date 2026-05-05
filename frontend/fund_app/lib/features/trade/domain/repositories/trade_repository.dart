import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/trade.dart';

abstract class TradeRepository {
  Future<Either<Failure, List<TradeRequest>>> getTradeHistory({int? limit, int? offset});
  Future<Either<Failure, TradeRequest>> getTradeRequest(int id);
  Future<Either<Failure, TradeRequest>> buyFund({required String fundCode, required double amount, int? portfolioId});
  Future<Either<Failure, TradeRequest>> sellFund({required String fundCode, required double shares});
  Future<Either<Failure, List<NavHistory>>> getNavHistory(String fundCode, {int days = 30});
}
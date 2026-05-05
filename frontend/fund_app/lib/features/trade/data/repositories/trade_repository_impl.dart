import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/trade.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/trade_remote_datasource.dart';

class TradeRepositoryImpl implements TradeRepository {
  final TradeRemoteDataSource _remoteDataSource;

  TradeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TradeRequest>>> getTradeHistory({int? limit, int? offset}) async {
    try {
      final history = await _remoteDataSource.getTradeHistory(limit: limit, offset: offset);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeRequest>> getTradeRequest(int id) async {
    try {
      final request = await _remoteDataSource.getTradeRequest(id);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeRequest>> buyFund({required String fundCode, required double amount, int? portfolioId}) async {
    try {
      final request = await _remoteDataSource.buyFund(fundCode: fundCode, amount: amount, portfolioId: portfolioId);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TradeRequest>> sellFund({required String fundCode, required double shares}) async {
    try {
      final request = await _remoteDataSource.sellFund(fundCode: fundCode, shares: shares);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NavHistory>>> getNavHistory(String fundCode, {int days = 30}) async {
    try {
      final history = await _remoteDataSource.getNavHistory(fundCode, days: days);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
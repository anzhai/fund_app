import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/fund.dart';
import '../../domain/repositories/fund_repository.dart';
import '../datasources/fund_remote_datasource.dart';

/// Fund Repository Implementation
class FundRepositoryImpl implements FundRepository {
  final FundRemoteDataSource _remoteDataSource;

  FundRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Fund>>> getFunds({
    String? fundType,
    String? riskLevel,
    String? keyword,
  }) async {
    try {
      final funds = await _remoteDataSource.getFunds(
        fundType: fundType,
        riskLevel: riskLevel,
        keyword: keyword,
      );
      return Right(funds);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Fund>> getFundDetail(String fundCode) async {
    try {
      final fund = await _remoteDataSource.getFundDetail(fundCode);
      return Right(fund);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFundNavHistory(
    String fundCode, {
    int days = 30,
  }) async {
    try {
      final history = await _remoteDataSource.getFundNavHistory(
        fundCode,
        days: days,
      );
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
  Future<Either<Failure, List<Fund>>> getFundRanking({
    String period = '1m',
  }) async {
    // TODO: Implement ranking API
    return const Right([]);
  }
}

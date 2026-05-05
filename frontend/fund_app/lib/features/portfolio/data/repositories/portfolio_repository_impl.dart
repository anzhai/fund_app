import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_remote_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource _remoteDataSource;

  PortfolioRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Portfolio>>> getPortfolios() async {
    try {
      final portfolios = await _remoteDataSource.getPortfolios();
      return Right(portfolios);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Portfolio>> getPortfolio(int id) async {
    try {
      final portfolio = await _remoteDataSource.getPortfolio(id);
      return Right(portfolio);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PortfolioFund>>> getPortfolioFunds(int portfolioId) async {
    try {
      final funds = await _remoteDataSource.getPortfolioFunds(portfolioId);
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
  Future<Either<Failure, Portfolio>> createPortfolio({required String name, String? description}) async {
    try {
      final portfolio = await _remoteDataSource.createPortfolio(name: name, description: description);
      return Right(portfolio);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePortfolio(int id) async {
    try {
      await _remoteDataSource.deletePortfolio(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioFund>> addFund({required int portfolioId, required String fundCode, required double amount}) async {
    try {
      final fund = await _remoteDataSource.addFund(
        portfolioId: portfolioId,
        fundCode: fundCode,
        amount: amount,
      );
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
  Future<Either<Failure, void>> removeFund({required int portfolioId, required String fundCode}) async {
    try {
      await _remoteDataSource.removeFund(portfolioId: portfolioId, fundCode: fundCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
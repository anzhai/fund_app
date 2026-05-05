import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      final wallet = await _remoteDataSource.getWallet();
      return Right(wallet);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> recharge({required double amount, int? bankCardId}) async {
    try {
      final wallet = await _remoteDataSource.recharge(amount: amount, bankCardId: bankCardId);
      return Right(wallet);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> withdraw({required double amount, required String withdrawType, int? bankCardId}) async {
    try {
      final wallet = await _remoteDataSource.withdraw(amount: amount, withdrawType: withdrawType, bankCardId: bankCardId);
      return Right(wallet);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TradeOrder>>> getOrders() async {
    try {
      final orders = await _remoteDataSource.getOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

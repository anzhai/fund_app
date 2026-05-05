import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remoteDataSource;

  AccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<BankCard>>> getBankCards() async {
    try {
      final cards = await _remoteDataSource.getBankCards();
      return Right(cards);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BankCard>> addBankCard({required String bankCode, required String cardNo, required String cardType}) async {
    try {
      final card = await _remoteDataSource.addBankCard(bankCode: bankCode, cardNo: cardNo, cardType: cardType);
      return Right(card);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBankCard(int id) async {
    try {
      await _remoteDataSource.deleteBankCard(id);
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
  Future<Either<Failure, void>> setDefaultBankCard(int id) async {
    try {
      await _remoteDataSource.setDefaultBankCard(id);
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
  Future<Either<Failure, RiskAssessment>> getRiskAssessment() async {
    try {
      final assessment = await _remoteDataSource.getRiskAssessment();
      return Right(assessment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiskAssessment>> submitRiskAssessment({required String level, required List<String> answers}) async {
    try {
      final assessment = await _remoteDataSource.submitRiskAssessment(level: level, answers: answers);
      return Right(assessment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountOpen>> openAccount({required String type}) async {
    try {
      final account = await _remoteDataSource.openAccount(type: type);
      return Right(account);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountOpen>>> getAccountOpens() async {
    try {
      final accounts = await _remoteDataSource.getAccountOpens();
      return Right(accounts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
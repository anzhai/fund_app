import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<BankCard>>> getBankCards();
  Future<Either<Failure, BankCard>> addBankCard({required String bankCode, required String cardNo, required String cardType});
  Future<Either<Failure, void>> deleteBankCard(int id);
  Future<Either<Failure, void>> setDefaultBankCard(int id);
  Future<Either<Failure, RiskAssessment>> getRiskAssessment();
  Future<Either<Failure, RiskAssessment>> submitRiskAssessment({required String level, required List<String> answers});
  Future<Either<Failure, AccountOpen>> openAccount({
    required String realName,
    required String idCard,
    required DateTime idCardExpire,
    required String tradePassword,
  });
  Future<Either<Failure, List<AccountOpen>>> getAccountOpens();
}
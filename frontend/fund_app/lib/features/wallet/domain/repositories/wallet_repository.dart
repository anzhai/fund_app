import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, Wallet>> recharge({required double amount, int? bankCardId});
  Future<Either<Failure, Wallet>> withdraw({required double amount, required String withdrawType, int? bankCardId});
  Future<Either<Failure, List<TradeOrder>>> getOrders();
}

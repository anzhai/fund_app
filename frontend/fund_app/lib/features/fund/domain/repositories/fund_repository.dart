import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fund.dart';

/// Fund Repository Interface
abstract class FundRepository {
  /// Get all funds
  Future<Either<Failure, List<Fund>>> getFunds({
    String? fundType,
    String? riskLevel,
    String? keyword,
  });

  /// Get fund detail by code
  Future<Either<Failure, Fund>> getFundDetail(String fundCode);

  /// Get fund NAV history
  Future<Either<Failure, List<Map<String, dynamic>>>> getFundNavHistory(
    String fundCode, {
    int days = 30,
  });

  /// Get fund ranking
  Future<Either<Failure, List<Fund>>> getFundRanking({String period = '1m'});
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/fund_remote_datasource.dart';
import '../../data/repositories/fund_repository_impl.dart';
import '../../domain/entities/fund.dart';
import '../../domain/repositories/fund_repository.dart';

// Data Source Provider
final fundRemoteDataSourceProvider = Provider<FundRemoteDataSource>((ref) {
  return FundRemoteDataSource(ApiClient());
});

// Repository Provider
final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepositoryImpl(ref.read(fundRemoteDataSourceProvider));
});

// Fund List State
class FundListState {
  final List<Fund> funds;
  final bool isLoading;
  final String? error;

  const FundListState({
    this.funds = const [],
    this.isLoading = false,
    this.error,
  });

  FundListState copyWith({
    List<Fund>? funds,
    bool? isLoading,
    String? error,
  }) {
    return FundListState(
      funds: funds ?? this.funds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Fund List Notifier
class FundListNotifier extends StateNotifier<FundListState> {
  final FundRepository _repository;

  FundListNotifier(this._repository) : super(const FundListState());

  Future<void> loadFunds({String? fundType, String? riskLevel, String? keyword}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getFunds(
      fundType: fundType,
      riskLevel: riskLevel,
      keyword: keyword,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (funds) => state = state.copyWith(isLoading: false, funds: funds),
    );
  }

  Future<void> seedFunds() async {
    try {
      final dataSource = FundRemoteDataSource(ApiClient());
      await dataSource.seedFunds();
      await loadFunds();
    } catch (e) {
      // Ignore seed errors
    }
  }
}

// Fund List Provider
final fundListProvider = StateNotifierProvider<FundListNotifier, FundListState>((ref) {
  return FundListNotifier(ref.read(fundRepositoryProvider));
});

// Selected Fund Provider
final selectedFundProvider = StateProvider<Fund?>((ref) => null);

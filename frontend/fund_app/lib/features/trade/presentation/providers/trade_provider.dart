import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/trade_remote_datasource.dart';
import '../../data/repositories/trade_repository_impl.dart';
import '../../domain/entities/trade.dart';
import '../../domain/repositories/trade_repository.dart';

final tradeRemoteDataSourceProvider = Provider<TradeRemoteDataSource>((ref) {
  return TradeRemoteDataSource(ApiClient());
});

final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  return TradeRepositoryImpl(ref.read(tradeRemoteDataSourceProvider));
});

class TradeState {
  final List<TradeRequest> history;
  final bool isLoading;
  final String? error;
  final TradeRequest? lastTrade;

  const TradeState({
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.lastTrade,
  });

  TradeState copyWith({
    List<TradeRequest>? history,
    bool? isLoading,
    String? error,
    TradeRequest? lastTrade,
  }) {
    return TradeState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastTrade: lastTrade ?? this.lastTrade,
    );
  }
}

class TradeNotifier extends StateNotifier<TradeState> {
  final TradeRepository _repository;

  TradeNotifier(this._repository) : super(const TradeState());

  Future<void> loadHistory({int? limit, int? offset}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getTradeHistory(limit: limit, offset: offset);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (history) => state = state.copyWith(isLoading: false, history: history),
    );
  }

  Future<bool> buyFund({required String fundCode, required double amount, int? portfolioId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.buyFund(fundCode: fundCode, amount: amount, portfolioId: portfolioId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (trade) {
        state = state.copyWith(isLoading: false, lastTrade: trade);
        return true;
      },
    );
  }

  Future<bool> sellFund({required String fundCode, required double shares}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.sellFund(fundCode: fundCode, shares: shares);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (trade) {
        state = state.copyWith(isLoading: false, lastTrade: trade);
        return true;
      },
    );
  }
}

final tradeProvider = StateNotifierProvider<TradeNotifier, TradeState>((ref) {
  return TradeNotifier(ref.read(tradeRepositoryProvider));
});
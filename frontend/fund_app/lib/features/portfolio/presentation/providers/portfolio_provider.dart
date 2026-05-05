import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/portfolio_remote_datasource.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/repositories/portfolio_repository.dart';

final portfolioRemoteDataSourceProvider = Provider<PortfolioRemoteDataSource>((ref) {
  return PortfolioRemoteDataSource(ApiClient());
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(ref.read(portfolioRemoteDataSourceProvider));
});

class PortfolioState {
  final List<Portfolio> portfolios;
  final Portfolio? selectedPortfolio;
  final List<PortfolioFund> funds;
  final bool isLoading;
  final String? error;

  const PortfolioState({
    this.portfolios = const [],
    this.selectedPortfolio,
    this.funds = const [],
    this.isLoading = false,
    this.error,
  });

  PortfolioState copyWith({
    List<Portfolio>? portfolios,
    Portfolio? selectedPortfolio,
    List<PortfolioFund>? funds,
    bool? isLoading,
    String? error,
  }) {
    return PortfolioState(
      portfolios: portfolios ?? this.portfolios,
      selectedPortfolio: selectedPortfolio ?? this.selectedPortfolio,
      funds: funds ?? this.funds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final PortfolioRepository _repository;

  PortfolioNotifier(this._repository) : super(const PortfolioState());

  Future<void> loadPortfolios() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getPortfolios();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (portfolios) => state = state.copyWith(isLoading: false, portfolios: portfolios),
    );
  }

  Future<void> loadPortfolio(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getPortfolio(id);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (portfolio) => state = state.copyWith(isLoading: false, selectedPortfolio: portfolio),
    );
  }

  Future<void> loadPortfolioFunds(int portfolioId) async {
    final result = await _repository.getPortfolioFunds(portfolioId);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (funds) => state = state.copyWith(funds: funds),
    );
  }

  Future<bool> createPortfolio({required String name, String? description}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.createPortfolio(name: name, description: description);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (portfolio) {
        state = state.copyWith(
          isLoading: false,
          portfolios: [...state.portfolios, portfolio],
        );
        return true;
      },
    );
  }

  Future<bool> deletePortfolio(int id) async {
    final result = await _repository.deletePortfolio(id);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          portfolios: state.portfolios.where((p) => p.id != id).toList(),
        );
        return true;
      },
    );
  }
}

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier(ref.read(portfolioRepositoryProvider));
});
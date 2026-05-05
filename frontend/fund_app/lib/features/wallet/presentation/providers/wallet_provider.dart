import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  return WalletRemoteDataSource(ApiClient());
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.read(walletRemoteDataSourceProvider));
});

class WalletState {
  final Wallet? wallet;
  final List<TradeOrder> orders;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.wallet,
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<TradeOrder>? orders,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getWallet();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (wallet) => state = state.copyWith(isLoading: false, wallet: wallet),
    );
  }

  Future<void> loadOrders() async {
    final result = await _repository.getOrders();
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (orders) => state = state.copyWith(orders: orders),
    );
  }

  Future<bool> recharge({required double amount, int? bankCardId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.recharge(amount: amount, bankCardId: bankCardId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (wallet) {
        state = state.copyWith(isLoading: false, wallet: wallet);
        return true;
      },
    );
  }

  Future<bool> withdraw({required double amount, required String withdrawType, int? bankCardId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.withdraw(
      amount: amount,
      withdrawType: withdrawType,
      bankCardId: bankCardId,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (wallet) {
        state = state.copyWith(isLoading: false, wallet: wallet);
        return true;
      },
    );
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.read(walletRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSource>((ref) {
  return AccountRemoteDataSource(ApiClient());
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.read(accountRemoteDataSourceProvider));
});

class AccountState {
  final List<BankCard> bankCards;
  final RiskAssessment? riskAssessment;
  final List<AccountOpen> accountOpens;
  final bool isLoading;
  final String? error;

  const AccountState({
    this.bankCards = const [],
    this.riskAssessment,
    this.accountOpens = const [],
    this.isLoading = false,
    this.error,
  });

  AccountState copyWith({
    List<BankCard>? bankCards,
    RiskAssessment? riskAssessment,
    List<AccountOpen>? accountOpens,
    bool? isLoading,
    String? error,
  }) {
    return AccountState(
      bankCards: bankCards ?? this.bankCards,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      accountOpens: accountOpens ?? this.accountOpens,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  final AccountRepository _repository;

  AccountNotifier(this._repository) : super(const AccountState());

  Future<void> loadBankCards() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getBankCards();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (cards) => state = state.copyWith(isLoading: false, bankCards: cards),
    );
  }

  Future<bool> addBankCard({required String bankCode, required String cardNo, required String cardType}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.addBankCard(bankCode: bankCode, cardNo: cardNo, cardType: cardType);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (card) {
        state = state.copyWith(isLoading: false, bankCards: [...state.bankCards, card]);
        return true;
      },
    );
  }

  Future<bool> deleteBankCard(int id) async {
    final result = await _repository.deleteBankCard(id);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(bankCards: state.bankCards.where((c) => c.id != id).toList());
        return true;
      },
    );
  }

  Future<void> loadRiskAssessment() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getRiskAssessment();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (assessment) => state = state.copyWith(isLoading: false, riskAssessment: assessment),
    );
  }

  Future<bool> submitRiskAssessment({required String level, required List<String> answers}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.submitRiskAssessment(level: level, answers: answers);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (assessment) {
        state = state.copyWith(isLoading: false, riskAssessment: assessment);
        return true;
      },
    );
  }

  Future<bool> openAccount({required String type}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.openAccount(type: type);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (account) {
        state = state.copyWith(isLoading: false, accountOpens: [...state.accountOpens, account]);
        return true;
      },
    );
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier(ref.read(accountRepositoryProvider));
});
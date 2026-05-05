import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/account_model.dart';

class AccountRemoteDataSource {
  final ApiClient _apiClient;

  AccountRemoteDataSource(this._apiClient);

  Future<List<BankCardModel>> getBankCards() async {
    final response = await _apiClient.get('${AppConstants.accountBaseUrl}/bank-cards');
    final List<dynamic> data = response.data;
    return data.map((json) => BankCardModel.fromJson(json)).toList();
  }

  Future<BankCardModel> addBankCard({required String bankCode, required String cardNo, required String cardType}) async {
    final response = await _apiClient.post(
      '${AppConstants.accountBaseUrl}/bank-card',
      data: {'bank_code': bankCode, 'card_no': cardNo, 'card_type': cardType},
    );
    return BankCardModel.fromJson(response.data);
  }

  Future<void> deleteBankCard(int id) async {
    await _apiClient.delete('${AppConstants.accountBaseUrl}/bank-card/$id');
  }

  Future<void> setDefaultBankCard(int id) async {
    await _apiClient.put('${AppConstants.accountBaseUrl}/bank-card/$id/default');
  }

  Future<RiskAssessmentModel> getRiskAssessment() async {
    final response = await _apiClient.get('${AppConstants.accountBaseUrl}/risk-assessment');
    return RiskAssessmentModel.fromJson(response.data);
  }

  Future<RiskAssessmentModel> submitRiskAssessment({required String level, required List<String> answers}) async {
    final response = await _apiClient.post(
      '${AppConstants.accountBaseUrl}/risk-assessment',
      data: {'level': level, 'answers': answers},
    );
    return RiskAssessmentModel.fromJson(response.data);
  }

  Future<AccountOpenModel> openAccount({
    required String realName,
    required String idCard,
    required DateTime idCardExpire,
    required String tradePassword,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.accountBaseUrl}/account/open',
      data: {
        'real_name': realName,
        'id_card': idCard,
        'id_card_expire': idCardExpire.toIso8601String(),
        'trade_password': tradePassword,
      },
    );
    
    // Backend returns {"message": "开户成功", "account_id": xxx}
    // Convert to AccountOpenModel format
    final responseData = response.data;
    return AccountOpenModel(
      id: responseData['account_id'] as int? ?? 0,
      userId: 0, // Will be fetched from auth context
      type: 'fund_account',
      status: 'active',
      createdAt: DateTime.now(),
    );
  }

  Future<List<AccountOpenModel>> getAccountOpens() async {
    final response = await _apiClient.get('${AppConstants.accountBaseUrl}/info');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => AccountOpenModel.fromJson(json)).toList();
  }
}
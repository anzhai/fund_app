import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<WalletModel> getWallet() async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/wallet/');
    return WalletModel.fromJson(response.data);
  }

  Future<WalletModel> recharge({required double amount, int? bankCardId}) async {
    final data = <String, dynamic>{'amount': amount};
    if (bankCardId != null) data['bank_card_id'] = bankCardId;
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/wallet/recharge',
      data: data,
    );
    return WalletModel.fromJson(response.data);
  }

  Future<WalletModel> withdraw({required double amount, required String withdrawType, int? bankCardId}) async {
    final data = {
      'amount': amount,
      'withdraw_type': withdrawType,
    };
    if (bankCardId != null) data['bank_card_id'] = bankCardId;
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/wallet/withdraw',
      data: data,
    );
    return WalletModel.fromJson(response.data);
  }

  Future<List<TradeOrderModel>> getOrders() async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/orders');
    final List<dynamic> data = response.data;
    return data.map((json) => TradeOrderModel.fromJson(json)).toList();
  }
}

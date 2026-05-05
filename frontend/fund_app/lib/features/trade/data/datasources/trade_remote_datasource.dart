import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/trade_model.dart';

class TradeRemoteDataSource {
  final ApiClient _apiClient;

  TradeRemoteDataSource(this._apiClient);

  Future<List<TradeRequestModel>> getTradeHistory({int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _apiClient.get(
      '${AppConstants.tradeBaseUrl}/trades/',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => TradeRequestModel.fromJson(json)).toList();
  }

  Future<TradeRequestModel> getTradeRequest(int id) async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/trades/$id');
    return TradeRequestModel.fromJson(response.data);
  }

  Future<TradeRequestModel> buyFund({required String fundCode, required double amount, int? portfolioId}) async {
    final data = <String, dynamic>{'fund_code': fundCode, 'amount': amount};
    if (portfolioId != null) data['portfolio_id'] = portfolioId;
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/trades/buy',
      data: data,
    );
    return TradeRequestModel.fromJson(response.data);
  }

  Future<TradeRequestModel> sellFund({required String fundCode, required double shares}) async {
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/trades/sell',
      data: {'fund_code': fundCode, 'shares': shares},
    );
    return TradeRequestModel.fromJson(response.data);
  }

  Future<List<NavHistoryModel>> getNavHistory(String fundCode, {int days = 30}) async {
    final response = await _apiClient.get(
      '${AppConstants.tradeBaseUrl}/nav-history/$fundCode',
      queryParameters: {'days': days},
    );
    final List<dynamic> data = response.data;
    final histories = <NavHistoryModel>[];
    for (var i = 0; i < data.length; i++) {
      final prevNav = i < data.length - 1 ? (data[i + 1]['nav'] as num).toDouble() : null;
      histories.add(NavHistoryModel.fromJson(data[i], prevNav: prevNav));
    }
    return histories;
  }
}
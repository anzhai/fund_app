import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/portfolio_model.dart';

class PortfolioRemoteDataSource {
  final ApiClient _apiClient;

  PortfolioRemoteDataSource(this._apiClient);

  Future<List<PortfolioModel>> getPortfolios() async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/portfolios/');
    final List<dynamic> data = response.data;
    return data.map((json) => PortfolioModel.fromJson(json)).toList();
  }

  Future<PortfolioModel> getPortfolio(int id) async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/portfolios/$id');
    return PortfolioModel.fromJson(response.data);
  }

  Future<List<PortfolioFundModel>> getPortfolioFunds(int portfolioId) async {
    final response = await _apiClient.get('${AppConstants.tradeBaseUrl}/portfolios/$portfolioId/funds');
    final List<dynamic> data = response.data;
    return data.map((json) => PortfolioFundModel.fromJson(json)).toList();
  }

  Future<PortfolioModel> createPortfolio({required String name, String? description}) async {
    final data = <String, dynamic>{'name': name};
    if (description != null) data['description'] = description;
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/portfolios/',
      data: data,
    );
    return PortfolioModel.fromJson(response.data);
  }

  Future<void> deletePortfolio(int id) async {
    await _apiClient.delete('${AppConstants.tradeBaseUrl}/portfolios/$id');
  }

  Future<PortfolioFundModel> addFund({required int portfolioId, required String fundCode, required double amount}) async {
    final response = await _apiClient.post(
      '${AppConstants.tradeBaseUrl}/portfolios/$portfolioId/funds',
      data: {'fund_code': fundCode, 'amount': amount},
    );
    return PortfolioFundModel.fromJson(response.data);
  }

  Future<void> removeFund({required int portfolioId, required String fundCode}) async {
    await _apiClient.delete('${AppConstants.tradeBaseUrl}/portfolios/$portfolioId/funds/$fundCode');
  }
}
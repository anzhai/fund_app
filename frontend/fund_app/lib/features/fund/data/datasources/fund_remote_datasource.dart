import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/fund_model.dart';

/// Fund Remote Data Source
class FundRemoteDataSource {
  final ApiClient _apiClient;

  FundRemoteDataSource(this._apiClient);

  /// Get fund list
  Future<List<FundModel>> getFunds({
    String? fundType,
    String? riskLevel,
    String? keyword,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fundType != null) queryParams['fund_type'] = fundType;
    if (riskLevel != null) queryParams['risk_level'] = riskLevel;
    if (keyword != null) queryParams['keyword'] = keyword;

    final uri = Uri.parse('${AppConstants.fundBaseUrl}/')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await _apiClient.get(uri.toString());
    final List<dynamic> data = response.data;
    return data.map((json) => FundModel.fromJson(json)).toList();
  }

  /// Get fund detail
  Future<FundModel> getFundDetail(String fundCode) async {
    final response = await _apiClient.get(
      '${AppConstants.fundBaseUrl}/$fundCode/detail',
    );
    return FundModel.fromJson(response.data);
  }

  /// Get fund NAV history
  Future<List<Map<String, dynamic>>> getFundNavHistory(
    String fundCode, {
    int days = 30,
  }) async {
    final response = await _apiClient.get(
      '${AppConstants.fundBaseUrl}/$fundCode/nav-history',
      queryParameters: {'days': days},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Seed fund data
  Future<void> seedFunds() async {
    await _apiClient.post('${AppConstants.fundBaseUrl}/seed');
  }
}

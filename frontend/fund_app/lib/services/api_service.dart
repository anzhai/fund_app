import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:8001'; // Direct to auth-service
  static const String authBaseUrl = '$baseUrl/auth';
  static const String accountBaseUrl = 'http://localhost:8002/account';
  static const String fundBaseUrl = 'http://localhost:8003/fund';
  static const String tradeBaseUrl = 'http://localhost:8005/trade';
  static const String portfolioBaseUrl = 'http://localhost:8004/portfolio';
}

// API Service
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  Future<String?> get accessToken async {
    if (_accessToken == null) {
      _accessToken = await storage.read(key: 'access_token');
    }
    return _accessToken;
  }

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await storage.write(key: 'access_token', value: access);
    await storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth APIs
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    String? idCard,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'id_card': idCard,
        'user_type': 'direct_sales',
      }),
    );
    final data = _handleResponse(response);
    // Store tokens from registration response
    if (data.containsKey('access_token') && data.containsKey('refresh_token')) {
      await setTokens(data['access_token'], data['refresh_token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String loginType,
    required String identifier,
    String? password,
    String? smsCode,
  }) async {
    final body = {
      'login_type': loginType,
      'identifier': identifier,
    };
    if (password != null) body['password'] = password;
    if (smsCode != null) body['sms_code'] = smsCode;

    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/login'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    final data = _handleResponse(response);
    await setTokens(data['access_token'], data['refresh_token']);
    return data;
  }

  Future<Map<String, dynamic>> sendSmsCode(String phone, String purpose) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/sms/send'),
      headers: await _getHeaders(),
      body: jsonEncode({'phone': phone, 'purpose': purpose}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.authBaseUrl}/me'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Account APIs
  Future<Map<String, dynamic>> openAccount({
    required String idCard,
    required String realName,
    required DateTime idCardExpire,
    required String tradePassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.accountBaseUrl}/open'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'id_card': idCard,
        'real_name': realName,
        'id_card_expire': idCardExpire.toIso8601String().split('T')[0],
        'trade_password': tradePassword,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAccountInfo() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.accountBaseUrl}/info'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addBankCard({
    required String bankName,
    required String bankCode,
    required String cardNumber,
    bool isDefault = false,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.accountBaseUrl}/bank-card'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'bank_name': bankName,
        'bank_code': bankCode,
        'card_number': cardNumber,
        'is_default': isDefault,
      }),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> listBankCards() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.accountBaseUrl}/bank-cards'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // Risk Assessment APIs
  Future<List<dynamic>> getRiskQuestions() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.accountBaseUrl}/risk/questions'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> submitRiskAssessment(List answers) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.accountBaseUrl}/risk/submit'),
      headers: await _getHeaders(),
      body: jsonEncode({'answers': answers}),
    );
    return _handleResponse(response);
  }

  // Fund APIs
  Future<List<dynamic>> listFunds({
    String? fundType,
    String? riskLevel,
    String? keyword,
  }) async {
    final params = <String, String>{};
    if (fundType != null) params['fund_type'] = fundType;
    if (riskLevel != null) params['risk_level'] = riskLevel;
    if (keyword != null) params['keyword'] = keyword;

    final uri = Uri.parse('${ApiConfig.fundBaseUrl}/').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _getHeaders());
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> getFundDetail(String fundCode) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.fundBaseUrl}/$fundCode/detail'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getFundRanking({String period = '1m'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.fundBaseUrl}/ranking?period=$period'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // Trade APIs
  Future<Map<String, dynamic>> purchase({
    required String fundCode,
    required double amount,
    String payMethod = 'wallet',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.tradeBaseUrl}/purchase'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'fund_code': fundCode,
        'amount': amount,
        'pay_method': payMethod,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> redeem({
    required String fundCode,
    required double shares,
    String redeemTo = 'wallet',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.tradeBaseUrl}/redeem'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'fund_code': fundCode,
        'shares': shares,
        'redeem_to': redeemTo,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createSIPPlan({
    required String fundCode,
    required double amount,
    required String frequency,
    required int dayOfPeriod,
    required DateTime startDate,
    String sipType = 'regular',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.tradeBaseUrl}/sip/create'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'fund_code': fundCode,
        'amount': amount,
        'frequency': frequency,
        'day_of_period': dayOfPeriod,
        'start_date': startDate.toIso8601String(),
        'sip_type': sipType,
      }),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> listSIPPlans() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.tradeBaseUrl}/sip/list'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<List<dynamic>> listTradeOrders() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.tradeBaseUrl}/orders'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // Wallet APIs
  Future<Map<String, dynamic>> getWallet() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.tradeBaseUrl}/wallet/'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> recharge({
    required double amount,
    int? bankCardId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.tradeBaseUrl}/wallet/recharge'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'amount': amount,
        'bank_card_id': bankCardId,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> withdraw({
    required double amount,
    String withdrawType = 'normal',
    int? bankCardId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.tradeBaseUrl}/wallet/withdraw'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'amount': amount,
        'withdraw_type': withdrawType,
        'bank_card_id': bankCardId,
      }),
    );
    return _handleResponse(response);
  }

  // Portfolio APIs
  Future<List<dynamic>> listPortfolios() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.portfolioBaseUrl}/'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createPortfolio({
    required String name,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.portfolioBaseUrl}/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'portfolio_name': name,
        'description': description,
      }),
    );
    return _handleResponse(response);
  }

  // Helper methods
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '请求失败');
    }
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '请求失败');
    }
  }
}

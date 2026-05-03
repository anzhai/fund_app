import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> checkAuth() async {
    try {
      final user = await _apiService.getCurrentUser();
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }
  }

  Future<void> login({
    required String loginType,
    required String identifier,
    String? password,
    String? smsCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(
        loginType: loginType,
        identifier: identifier,
        password: password,
        smsCode: smsCode,
      );
      await checkAuth();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String phone,
    required String password,
    String? idCard,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(
        phone: phone,
        password: password,
        idCard: idCard,
      );
      // Set tokens after successful registration
      await _apiService.setTokens(result['access_token'], result['refresh_token']);
      await checkAuth();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.clearTokens();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> sendSmsCode(String phone, String purpose) async {
    await _apiService.sendSmsCode(phone, purpose);
  }
}

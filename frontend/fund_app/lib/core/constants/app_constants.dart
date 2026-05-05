class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = '基金组合管理';
  static const String appVersion = '1.0.0';

  // API Base URLs (Direct to services for development)
  static const String authBaseUrl = 'http://localhost:8001/auth';
  static const String accountBaseUrl = 'http://localhost:8002/account';
  static const String fundBaseUrl = 'http://localhost:8003/fund';
  static const String tradeBaseUrl = 'http://localhost:8005/trade';
  static const String portfolioBaseUrl = 'http://localhost:8004/portfolio';

  // Token Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int phoneLength = 11;
  static const int idCardLength = 18;
  static const int tradePasswordLength = 6;
}

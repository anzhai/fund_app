class ApiConfig {
  static const String baseUrl = 'http://localhost:80/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Fund endpoints
  static const String funds = '/fund/';
  static const String fundDetail = '/fund/';
  static const String fundNavHistory = '/fund/';

  // Portfolio endpoints
  static const String portfolios = '/portfolio/';
  static const String portfolioDetail = '/portfolio/';

  // Trade endpoints
  static const String purchase = '/trade/purchase';
  static const String redeem = '/trade/redeem';
  static const String tradeOrders = '/trade/orders';

  // Wallet endpoints
  static const String wallet = '/wallet/';
  static const String recharge = '/wallet/recharge';
  static const String withdraw = '/wallet/withdraw';

  // Account endpoints
  static const String openAccount = '/account/open';
  static const String addBankCard = '/account/bank-card';

  // Risk endpoints
  static const String riskQuestions = '/risk/questions';
  static const String riskSubmit = '/risk/submit';
}

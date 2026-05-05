import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/fund/presentation/screens/fund_list_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/trade/presentation/screens/trade_screen.dart';
import '../../features/user/presentation/screens/user_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../widgets/main_scaffold.dart';

class AccountOpenScreen extends StatelessWidget {
  const AccountOpenScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('开户')));
}

class RiskAssessmentScreen extends StatelessWidget {
  const RiskAssessmentScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('风险测评')));
}

class BankCardScreen extends StatelessWidget {
  const BankCardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('银行卡')));
}

class TradeHistoryScreen extends StatelessWidget {
  const TradeHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('交易历史')));
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes (with bottom navigation)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/funds',
            name: 'funds',
            builder: (context, state) => const FundListScreen(),
          ),
          GoRoute(
            path: '/portfolio',
            name: 'portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/trade',
            name: 'trade',
            builder: (context, state) => const TradeScreen(),
          ),
          GoRoute(
            path: '/user',
            name: 'user',
            builder: (context, state) => const UserScreen(),
          ),
        ],
      ),

      // Full Screen Routes
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/account-open',
        name: 'account-open',
        builder: (context, state) => const AccountOpenScreen(),
      ),
      GoRoute(
        path: '/account/risk-assessment',
        name: 'risk-assessment',
        builder: (context, state) => const RiskAssessmentScreen(),
      ),
      GoRoute(
        path: '/bank-cards',
        name: 'bank-cards',
        builder: (context, state) => const BankCardScreen(),
      ),
      GoRoute(
        path: '/trade/history',
        name: 'trade-history',
        builder: (context, state) => const TradeHistoryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
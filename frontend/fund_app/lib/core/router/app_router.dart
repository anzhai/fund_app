import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/register_success_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/fund/presentation/screens/fund_list_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/trade/presentation/screens/trade_screen.dart';
import '../../features/user/presentation/screens/user_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/account/presentation/screens/account_open_screen.dart';
import '../../features/account/presentation/screens/account_open_success_screen.dart';
import '../../features/account/presentation/screens/risk_assessment_screen.dart';
import '../../features/account/presentation/screens/bank_card_screen.dart';
import '../../features/trade/presentation/screens/trade_history_screen.dart';
import '../widgets/main_scaffold.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Router Provider with Auth Guard
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPage = state.uri.path == '/login' || 
                         state.uri.path == '/register' ||
                         state.uri.path == '/register-success';
      
      // 如果未认证且不在认证相关页面，重定向到登录页
      if (!isAuthenticated && !isAuthPage) {
        return '/login';
      }
      
      // 如果已认证且在登录/注册页面（不包括注册成功页），重定向到首页
      if (isAuthenticated && (state.uri.path == '/login' || state.uri.path == '/register')) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Auth Routes (公开路由)
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
      GoRoute(
        path: '/register-success',
        name: 'register-success',
        builder: (context, state) => const RegisterSuccessScreen(),
      ),

      // Protected Routes (需要认证)
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

      // Full Screen Protected Routes
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
        path: '/account-open-success',
        name: 'account-open-success',
        builder: (context, state) => const AccountOpenSuccessScreen(),
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

/// Helper class to make StateNotifier listenable by GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}

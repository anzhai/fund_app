import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/home_page.dart';
import '../../features/fund/fund_list_page.dart';
import '../../features/fund/fund_detail_page.dart';
import '../../features/portfolio/portfolio_page.dart';
import '../../features/trade/trade_page.dart';
import '../../features/trade/purchase_page.dart';
import '../../features/wallet/wallet_page.dart';
import '../../features/user/user_page.dart';
import '../../features/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/fund',
            builder: (context, state) => const FundListPage(),
            routes: [
              GoRoute(
                path: 'detail/:code',
                builder: (context, state) => FundDetailPage(
                  fundCode: state.pathParameters['code']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/portfolio',
            builder: (context, state) => const PortfolioPage(),
          ),
          GoRoute(
            path: '/trade',
            builder: (context, state) => const TradePage(),
            routes: [
              GoRoute(
                path: 'purchase/:code',
                builder: (context, state) => PurchasePage(
                  fundCode: state.pathParameters['code']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletPage(),
          ),
          GoRoute(
            path: '/user',
            builder: (context, state) => const UserPage(),
          ),
        ],
      ),
    ],
  );
});

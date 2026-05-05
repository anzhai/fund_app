import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main Scaffold with Bottom Navigation
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const _mainRoutes = ['/', '/funds', '/portfolio', '/trade', '/user'];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location.startsWith('/funds')) return 1;
    if (location.startsWith('/portfolio')) return 2;
    if (location.startsWith('/trade')) return 3;
    if (location.startsWith('/user')) return 4;
    return 0;
  }

  bool _isMainRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return _mainRoutes.contains(location);
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/funds');
        break;
      case 2:
        context.go('/portfolio');
        break;
      case 3:
        context.go('/trade');
        break;
      case 4:
        context.go('/user');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _isMainRoute(context)
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(context, index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_outlined),
                  activeIcon: Icon(Icons.account_balance),
                  label: '基金',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_outline),
                  activeIcon: Icon(Icons.pie_chart),
                  label: '组合',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz_outlined),
                  activeIcon: Icon(Icons.swap_horiz),
                  label: '交易',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            )
          : null,
    );
  }
}

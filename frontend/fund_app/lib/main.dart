import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Client
  ApiClient().init();

  runApp(const ProviderScope(child: FundApp()));
}

class FundApp extends ConsumerWidget {
  const FundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    // Check authentication status on app start
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Auto-check auth when provider changes
    });
    
    // Trigger auth check on first build
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });

    return MaterialApp.router(
      title: '基金组合管理',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

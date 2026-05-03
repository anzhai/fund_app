import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fund_app/main.dart';

void main() {
  group('FundApp - Widget Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = const FundApp();
    });

    testWidgets('App loads and shows MainPage with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Verify bottom navigation bar exists with 5 items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('基金'), findsOneWidget);
      expect(find.text('组合'), findsOneWidget);
      expect(find.text('交易'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('AppBar shows correct title for Home tab', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      expect(find.text('基金组合管理'), findsOneWidget);
    });

    testWidgets('Home tab displays asset card with total assets', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      expect(find.text('总资产'), findsOneWidget);
      expect(find.text('¥ 0.00'), findsOneWidget);
    });

    testWidgets('Home tab displays quick action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      expect(find.text('快捷操作'), findsOneWidget);
      expect(find.text('充值'), findsOneWidget);
      expect(find.text('购买'), findsOneWidget);
      expect(find.text('定投'), findsOneWidget);
      expect(find.text('记录'), findsOneWidget);
    });

    testWidgets('Bottom navigation switches tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Tap on Fund tab
      await tester.tap(find.text('基金'));
      await tester.pumpAndSettle();
      expect(find.text('基金超市'), findsOneWidget);

      // Tap on Portfolio tab
      await tester.tap(find.text('组合'));
      await tester.pumpAndSettle();
      expect(find.text('我的组合'), findsOneWidget);

      // Tap on Trade tab
      await tester.tap(find.text('交易'));
      await tester.pumpAndSettle();
      expect(find.text('交易功能'), findsOneWidget);

      // Tap on User tab
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(find.text('个人信息'), findsOneWidget);

      // Back to Home tab
      await tester.tap(find.text('首页'));
      await tester.pumpAndSettle();
      expect(find.text('基金组合管理'), findsOneWidget);
    });
  });

  group('HomeTab Tests', () {
    testWidgets('HomeTab shows income info cards', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      expect(find.text('昨日收益 +0.00'), findsOneWidget);
      expect(find.text('累计收益 +0.00'), findsOneWidget);
    });

    testWidgets('HomeTab quick action buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      // Find and tap the quick action buttons
      final quickActions = find.byType(InkWell);
      expect(quickActions, findsWidgets);
    });
  });

  group('FundTab Tests', () {
    testWidgets('FundTab shows fund list with 4 funds', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      // Navigate to Fund tab
      await tester.tap(find.text('基金'));
      await tester.pumpAndSettle();

      expect(find.text('基金超市'), findsOneWidget);
      expect(find.text('货币基金A'), findsOneWidget);
      expect(find.text('股票基金B'), findsOneWidget);
      expect(find.text('混合基金C'), findsOneWidget);
      expect(find.text('FOF基金D'), findsOneWidget);
    });

    testWidgets('FundTab shows fund details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('基金'));
      await tester.pumpAndSettle();

      // Check fund names
      expect(find.text('货币基金A'), findsOneWidget);
      expect(find.text('股票基金B'), findsOneWidget);
      expect(find.text('混合基金C'), findsOneWidget);
      expect(find.text('FOF基金D'), findsOneWidget);

      // Check NAV values
      expect(find.text('¥1.0000'), findsOneWidget);
      expect(find.text('¥2.5000'), findsOneWidget);
      expect(find.text('¥1.8000'), findsOneWidget);
      expect(find.text('¥1.2000'), findsOneWidget);
    });

    testWidgets('FundTab shows fund codes and types correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('基金'));
      await tester.pumpAndSettle();

      // Check fund codes and types displayed as "code | type"
      expect(find.text('000001 | 货币基金'), findsOneWidget);
      expect(find.text('000002 | 股票基金'), findsOneWidget);
      expect(find.text('000003 | 混合基金'), findsOneWidget);
      expect(find.text('000004 | FOF基金'), findsOneWidget);
    });
  });

  group('PortfolioTab Tests', () {
    testWidgets('PortfolioTab shows empty state message', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('组合'));
      await tester.pumpAndSettle();

      expect(find.text('我的组合'), findsOneWidget);
      expect(find.text('暂无组合，点击创建'), findsOneWidget);
    });
  });

  group('TradeTab Tests', () {
    testWidgets('TradeTab shows trade placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pumpAndSettle();

      expect(find.text('交易功能'), findsOneWidget);
    });
  });

  group('UserTab Tests', () {
    testWidgets('UserTab shows user menu items', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('个人信息'), findsOneWidget);
      expect(find.text('钱包'), findsOneWidget);
      expect(find.text('银行卡'), findsOneWidget);
      expect(find.text('风险测评'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('UserTab shows settings icon', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
      expect(find.byIcon(Icons.assessment), findsOneWidget);
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Complete navigation flow through all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      // Start at Home
      expect(find.text('基金组合管理'), findsOneWidget);

      // Navigate to Fund
      await tester.tap(find.byIcon(Icons.account_balance_outlined));
      await tester.pumpAndSettle();
      expect(find.text('基金超市'), findsOneWidget);

      // Navigate to Portfolio
      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pumpAndSettle();
      expect(find.text('我的组合'), findsOneWidget);

      // Navigate to Trade
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pumpAndSettle();
      expect(find.text('交易功能'), findsOneWidget);

      // Navigate to User
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('个人信息'), findsOneWidget);

      // Back to Home
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('基金组合管理'), findsOneWidget);
    });
  });

  group('Widget Interactions', () {
    testWidgets('Quick action buttons respond to tap', (WidgetTester tester) async {
      await tester.pumpWidget(const FundApp());
      await tester.pumpAndSettle();

      // Find quick action buttons
      final buttons = find.widgetWithText(InkWell, '充值');
      expect(buttons, findsOneWidget);

      // Tap button
      await tester.tap(buttons);
      await tester.pump();
    });
  });
}
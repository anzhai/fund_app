import 'package:flutter/material.dart';

void main() {
  runApp(const FundApp());
}

class FundApp extends StatelessWidget {
  const FundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '基金组合管理',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    FundTab(),
    PortfolioTab(),
    TradeTab(),
    UserTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), label: '基金'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: '组合'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_outlined), label: '交易'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基金组合管理')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('总资产', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('¥ 0.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text('昨日收益 +0.00', style: TextStyle(color: Colors.green))),
                        Expanded(child: Text('累计收益 +0.00', style: TextStyle(color: Colors.green))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('快捷操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: const [
                _QuickActionButton(icon: Icons.account_balance_wallet, label: '充值'),
                _QuickActionButton(icon: Icons.shopping_cart, label: '购买'),
                _QuickActionButton(icon: Icons.swap_horiz, label: '定投'),
                _QuickActionButton(icon: Icons.history, label: '记录'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class FundTab extends StatelessWidget {
  const FundTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基金超市')),
      body: ListView(
        children: const [
          _FundCard('000001', '货币基金A', 'money_market', 'R1', '1.0000', '+0.00%'),
          _FundCard('000002', '股票基金B', 'stock', 'R5', '2.5000', '+2.04%'),
          _FundCard('000003', '混合基金C', 'hybrid', 'R3', '1.8000', '-1.10%'),
          _FundCard('000004', 'FOF基金D', 'fof', 'R4', '1.2000', '+0.84%'),
        ],
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  final String code;
  final String name;
  final String type;
  final String risk;
  final String nav;
  final String change;

  const _FundCard(this.code, this.name, this.type, this.risk, this.nav, this.change);

  String _getTypeName(String type) {
    switch (type) {
      case 'money_market': return '货币基金';
      case 'stock': return '股票基金';
      case 'hybrid': return '混合基金';
      case 'fof': return 'FOF基金';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$code | ${_getTypeName(type)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('¥$nav', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(change, style: TextStyle(color: isPositive ? Colors.red : Colors.green, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioTab extends StatelessWidget {
  const PortfolioTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的组合')),
      body: const Center(child: Text('暂无组合，点击创建')),
    );
  }
}

class TradeTab extends StatelessWidget {
  const TradeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('交易')),
      body: const Center(child: Text('交易功能')),
    );
  }
}

class UserTab extends StatelessWidget {
  const UserTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text('个人信息')),
          ListTile(leading: Icon(Icons.account_balance_wallet), title: Text('钱包')),
          ListTile(leading: Icon(Icons.credit_card), title: Text('银行卡')),
          ListTile(leading: Icon(Icons.assessment), title: Text('风险测评')),
          ListTile(leading: Icon(Icons.settings), title: Text('设置')),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基金组合管理'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('总资产', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    const Text(
                      '¥ 0.00',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('昨日收益', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              const Text('+0.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('累计收益', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              const Text('+0.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('快捷操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickActionButton(
                  icon: Icons.account_balance_wallet,
                  label: '充值',
                  onTap: () => context.go('/wallet'),
                ),
                _QuickActionButton(
                  icon: Icons.shopping_cart,
                  label: '购买',
                  onTap: () => context.go('/funds'),
                ),
                _QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: '定投',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('定投功能')),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.history,
                  label: '记录',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('交易记录')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fund Ranking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('基金排行', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.go('/funds'),
                  child: const Text('查看更多'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _RankingItem(rank: 1, name: '易方达消费行业股票', code: '000009', nav: '3.2500', change: '+2.04%'),
                  const Divider(height: 1),
                  _RankingItem(rank: 2, name: '华夏科技创新股票', code: '000010', nav: '2.8900', change: '+1.85%'),
                  const Divider(height: 1),
                  _RankingItem(rank: 3, name: '南方医药健康股票', code: '000012', nav: '3.1200', change: '+1.52%'),
                ],
              ),
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
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final String code;
  final String nav;
  final String change;

  const _RankingItem({
    required this.rank,
    required this.name,
    required this.code,
    required this.nav,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank <= 3 ? Colors.red[50] : Colors.grey[100],
        child: Text(
          '$rank',
          style: TextStyle(color: rank <= 3 ? Colors.red : Colors.grey[600]),
        ),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(code, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('¥$nav', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(change, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}

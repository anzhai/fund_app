import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'fund_list_page.dart';

class FundDetailPage extends ConsumerWidget {
  final String fundCode;

  const FundDetailPage({super.key, required this.fundCode});

  String _getFundTypeName(String type) {
    switch (type) {
      case 'money_market': return '货币基金';
      case 'stock': return '股票基金';
      case 'hybrid': return '混合基金';
      case 'fof': return 'FOF基金';
      default: return type;
    }
  }

  String _getRiskLevelName(String level) {
    switch (level) {
      case 'R1': return '低风险';
      case 'R2': return '中低风险';
      case 'R3': return '中风险';
      case 'R4': return '中高风险';
      case 'R5': return '高风险';
      default: return level;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final fund = funds.firstWhere((f) => f.fundCode == fundCode);

    return Scaffold(
      appBar: AppBar(title: Text(fund.fundName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Text('¥${fund.nav.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('日涨跌: ${fund.dailyGain >= 0 ? '+' : ''}${fund.dailyGain.toStringAsFixed(4)}',
                          style: TextStyle(color: fund.dailyGain >= 0 ? Colors.red : Colors.green)),
                      const SizedBox(width: 16),
                      Text('${fund.dailyGain >= 0 ? '+' : ''}${fund.dailyGainRatio.toStringAsFixed(2)}%',
                          style: TextStyle(color: fund.dailyGain >= 0 ? Colors.red : Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(title: const Text('基金代码'), trailing: Text(fund.fundCode)),
                const Divider(),
                ListTile(title: const Text('基金类型'), trailing: Text(_getFundTypeName(fund.fundType))),
                const Divider(),
                ListTile(title: const Text('风险等级'), trailing: Text(_getRiskLevelName(fund.riskLevel))),
                const Divider(),
                const ListTile(title: Text('基金公司'), trailing: Text('华夏基金')),
                const Divider(),
                const ListTile(title: Text('基金经理'), trailing: Text('张经理')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go('/trade/purchase/$fundCode'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text('立即购买'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
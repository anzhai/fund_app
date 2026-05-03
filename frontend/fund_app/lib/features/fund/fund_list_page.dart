import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Fund {
  final String fundCode;
  final String fundName;
  final String fundType;
  final String riskLevel;
  final double nav;
  final double dailyGain;
  final double dailyGainRatio;

  Fund(this.fundCode, this.fundName, this.fundType, this.riskLevel, this.nav, this.dailyGain, this.dailyGainRatio);
}

final fundsProvider = Provider<List<Fund>>((ref) => [
  Fund('000001', '货币基金A', 'money_market', 'R1', 1.0000, 0.00, 0.00),
  Fund('000002', '股票基金B', 'stock', 'R5', 2.5000, 0.05, 2.04),
  Fund('000003', '混合基金C', 'hybrid', 'R3', 1.8000, -0.02, -1.10),
  Fund('000004', 'FOF基金D', 'fof', 'R4', 1.2000, 0.01, 0.84),
]);

class FundListPage extends ConsumerWidget {
  const FundListPage({super.key});

  String _getFundTypeName(String type) {
    switch (type) {
      case 'money_market': return '货币基金';
      case 'stock': return '股票基金';
      case 'hybrid': return '混合基金';
      case 'fof': return 'FOF基金';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('基金超市'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: funds.length,
        itemBuilder: (context, index) {
          final fund = funds[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => context.go('/fund/detail/${fund.fundCode}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fund.fundName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('${fund.fundCode} | ${_getFundTypeName(fund.fundType)}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('¥${fund.nav.toStringAsFixed(4)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: fund.dailyGain >= 0 ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${fund.dailyGain >= 0 ? '+' : ''}${fund.dailyGainRatio.toStringAsFixed(2)}%',
                            style: TextStyle(color: fund.dailyGain >= 0 ? Colors.red : Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
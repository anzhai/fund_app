import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../trade/presentation/providers/trade_provider.dart';

class TradeHistoryScreen extends ConsumerStatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  ConsumerState<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends ConsumerState<TradeHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tradeProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tradeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('交易历史'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '暂无交易记录',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final trade = state.history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          trade.type == 'buy' ? Icons.arrow_upward : Icons.arrow_downward,
                          color: trade.type == 'buy' ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          '${trade.type == 'buy' ? '买入' : '卖出'} ${trade.fundName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${trade.amount.toStringAsFixed(2)} 元 | ${trade.shares.toStringAsFixed(2)} 份',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trade.status,
                              style: TextStyle(
                                color: trade.status == '成功' ? Colors.green : Colors.orange,
                              ),
                            ),
                            Text(
                              _formatDate(trade.createdAt),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
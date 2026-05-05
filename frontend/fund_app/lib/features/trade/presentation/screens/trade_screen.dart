import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/account_guard.dart';
import '../../domain/entities/trade.dart';
import '../providers/trade_provider.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(tradeProvider.notifier).loadHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '买入'),
            Tab(text: '卖出'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BuyTab(),
          _SellTab(),
        ],
      ),
    );
  }
}

class _BuyTab extends ConsumerWidget {
  const _BuyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tradeProvider);

    return SingleChildScrollView(
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
                  const Text('买入基金', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '基金代码',
                      hintText: '请输入基金代码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '买入金额',
                      prefixText: '¥ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleBuy(context, ref),
                      child: const Text('确认买入'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildHistorySection(context, state),
        ],
      ),
    );
  }

  Future<void> _handleBuy(BuildContext context, WidgetRef ref) async {
    final result = await AccountGuard.verify(ref: ref, context: context);
    if (!context.mounted) return;

    switch (result) {
      case AccountVerificationResult.verified:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('买入功能')),
        );
        break;
      case AccountVerificationResult.needOpenAccount:
      case AccountVerificationResult.needRiskAssessment:
      case AccountVerificationResult.riskAssessmentExpired:
      case AccountVerificationResult.riskLevelMismatch:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.notLoggedIn:
        break;
    }
  }

  Widget _buildHistorySection(BuildContext context, TradeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('买入记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/trade/history'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.history.where((t) => t.isBuy).isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('暂无买入记录'))))
        else
          Card(
            child: Column(
              children: state.history.where((t) => t.isBuy).take(3).map((t) => _TradeItem(trade: t)).toList(),
            ),
          ),
      ],
    );
  }
}

class _SellTab extends ConsumerWidget {
  const _SellTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tradeProvider);

    return SingleChildScrollView(
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
                  const Text('卖出基金', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '基金代码',
                      hintText: '请输入基金代码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '卖出份额',
                      hintText: '请输入卖出份额',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleSell(context, ref),
                      child: const Text('确认卖出'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildHistorySection(context, state),
        ],
      ),
    );
  }

  Future<void> _handleSell(BuildContext context, WidgetRef ref) async {
    final result = await AccountGuard.verify(ref: ref, context: context);
    if (!context.mounted) return;

    switch (result) {
      case AccountVerificationResult.verified:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('卖出功能')),
        );
        break;
      case AccountVerificationResult.needOpenAccount:
      case AccountVerificationResult.needRiskAssessment:
      case AccountVerificationResult.riskAssessmentExpired:
      case AccountVerificationResult.riskLevelMismatch:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.notLoggedIn:
        break;
    }
  }

  Widget _buildHistorySection(BuildContext context, TradeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('卖出记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/trade/history'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.history.where((t) => !t.isBuy).isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('暂无卖出记录'))))
        else
          Card(
            child: Column(
              children: state.history.where((t) => !t.isBuy).take(3).map((t) => _TradeItem(trade: t)).toList(),
            ),
          ),
      ],
    );
  }
}

class _TradeItem extends StatelessWidget {
  final TradeRequest trade;

  const _TradeItem({required this.trade});

  Color _getStatusColor(String status) {
    if (status == 'completed') return Colors.green;
    if (status == 'failed') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    final isBuy = trade.isBuy;

    return ListTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isBuy ? Colors.red : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(isBuy ? '买入' : '卖出', style: TextStyle(color: isBuy ? Colors.red : Colors.green, fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(trade.fundName, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
      subtitle: Text(dateFormat.format(trade.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(currencyFormat.format(trade.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(trade.status, style: TextStyle(color: _getStatusColor(trade.status), fontSize: 11)),
        ],
      ),
    );
  }
}
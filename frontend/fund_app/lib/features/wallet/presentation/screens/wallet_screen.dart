import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/account_guard.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
      ref.read(walletProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的钱包'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? AppErrorWidget(message: state.error!)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(walletProvider.notifier).loadWallet();
                    await ref.read(walletProvider.notifier).loadOrders();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWalletCard(state.wallet),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                        const SizedBox(height: 24),
                        _buildOrdersSection(state.orders),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWalletCard(Wallet? wallet) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('账户余额', style: TextStyle(color: Colors.grey[600])),
                Icon(Icons.account_balance_wallet, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(wallet?.balance ?? 0),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('冻结金额', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(wallet?.frozenAmount ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('可用金额', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format((wallet?.balance ?? 0) - (wallet?.frozenAmount ?? 0)),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleRecharge(context),
            icon: const Icon(Icons.add),
            label: const Text('充值'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleWithdraw(context),
            icon: const Icon(Icons.remove),
            label: const Text('提现'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRecharge(BuildContext context) async {
    final result = await AccountGuard.verify(ref: ref, context: context);
    if (!mounted) return;

    switch (result) {
      case AccountVerificationResult.verified:
        _showRechargeDialog(context);
        break;
      case AccountVerificationResult.needOpenAccount:
      case AccountVerificationResult.needRiskAssessment:
      case AccountVerificationResult.riskAssessmentExpired:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.riskLevelMismatch:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.notLoggedIn:
        break;
    }
  }

  Future<void> _handleWithdraw(BuildContext context) async {
    final result = await AccountGuard.verify(ref: ref, context: context);
    if (!mounted) return;

    switch (result) {
      case AccountVerificationResult.verified:
        _showWithdrawDialog(context);
        break;
      case AccountVerificationResult.needOpenAccount:
      case AccountVerificationResult.needRiskAssessment:
      case AccountVerificationResult.riskAssessmentExpired:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.riskLevelMismatch:
        // Dialog already shown by AccountGuard
        break;
      case AccountVerificationResult.notLoggedIn:
        break;
    }
  }

  Widget _buildOrdersSection(List<TradeOrder> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('交易记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const EmptyWidget(message: '暂无交易记录')
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _OrderItem(order: orders[index]),
            ),
          ),
      ],
    );
  }

  void _showRechargeDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('充值'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '充值金额',
            prefixText: '¥ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await ref.read(walletProvider.notifier).recharge(amount: amount);
                if (success && mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('充值成功')),
                  );
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final amountController = TextEditingController();
    String withdrawType = '银行卡';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('提现'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '提现金额',
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: withdrawType,
                decoration: const InputDecoration(
                  labelText: '提现方式',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '银行卡', child: Text('银行卡')),
                  DropdownMenuItem(value: '支付宝', child: Text('支付宝')),
                ],
                onChanged: (value) => setState(() => withdrawType = value ?? '银行卡'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  final success = await ref.read(walletProvider.notifier).withdraw(
                    amount: amount,
                    withdrawType: withdrawType,
                  );
                  if (success && mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('提现成功')),
                    );
                  }
                }
              },
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final TradeOrder order;

  const _OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    final isBuy = order.type == 'buy';
    final typeColor = isBuy ? Colors.red : Colors.green;
    final typeText = isBuy ? '买入' : '卖出';

    return ListTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(typeText, style: TextStyle(color: typeColor, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(order.fundName, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
      subtitle: Text(
        dateFormat.format(order.createdAt),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isBuy ? '-' : '+'}${currencyFormat.format(order.amount)}',
            style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
          ),
          Text(
            '${order.shares.toStringAsFixed(2)}份',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
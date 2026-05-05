import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/portfolio.dart';
import '../providers/portfolio_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(portfolioProvider.notifier).loadPortfolios());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的组合'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? AppErrorWidget(message: state.error!)
              : state.portfolios.isEmpty
                  ? const EmptyWidget(message: '暂无组合，点击右上角创建')
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(portfolioProvider.notifier).loadPortfolios();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.portfolios.length,
                        itemBuilder: (context, index) {
                          return _PortfolioCard(portfolio: state.portfolios[index]);
                        },
                      ),
                    ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建组合'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '组合名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await ref.read(portfolioProvider.notifier).createPortfolio(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                );
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final Portfolio portfolio;

  const _PortfolioCard({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPortfolioDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(portfolio.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              if (portfolio.description != null) ...[
                const SizedBox(height: 4),
                Text(portfolio.description!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('总资产', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(portfolio.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('今日收益', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(portfolio.todayProfit),
                          style: TextStyle(
                            color: portfolio.todayProfit >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('累计收益', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${(portfolio.profitRate * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: portfolio.profitRate >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPortfolioDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _PortfolioDetailSheet(
          portfolio: portfolio,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _PortfolioDetailSheet extends ConsumerStatefulWidget {
  final Portfolio portfolio;
  final ScrollController scrollController;

  const _PortfolioDetailSheet({
    required this.portfolio,
    required this.scrollController,
  });

  @override
  ConsumerState<_PortfolioDetailSheet> createState() => _PortfolioDetailSheetState();
}

class _PortfolioDetailSheetState extends ConsumerState<_PortfolioDetailSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(portfolioProvider.notifier).loadPortfolioFunds(widget.portfolio.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioProvider);
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.portfolio.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(currencyFormat.format(widget.portfolio.totalAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: state.funds.isEmpty
              ? const EmptyWidget(message: '暂无持仓基金')
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.funds.length,
                  itemBuilder: (context, index) {
                    final fund = state.funds[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(fund.fundName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('${fund.shares.toStringAsFixed(2)}份 · 成本 ¥${fund.cost.toStringAsFixed(2)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('¥${fund.marketValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${fund.profitRate >= 0 ? '+' : ''}${(fund.profitRate * 100).toStringAsFixed(2)}%',
                              style: TextStyle(color: fund.profitRate >= 0 ? Colors.green : Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
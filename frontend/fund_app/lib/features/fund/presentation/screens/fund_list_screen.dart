import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/account_guard.dart';
import '../../domain/entities/fund.dart';
import '../providers/fund_provider.dart';
import '../widgets/fund_card.dart';

class FundListScreen extends ConsumerStatefulWidget {
  const FundListScreen({super.key});

  @override
  ConsumerState<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends ConsumerState<FundListScreen> {
  @override
  void initState() {
    super.initState();
    // Load funds when screen opens
    Future.microtask(() {
      ref.read(fundListProvider.notifier).loadFunds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fundListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('基金超市'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(fundListProvider.notifier).loadFunds(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(FundListState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: '加载基金列表...');
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(fundListProvider.notifier).loadFunds(),
      );
    }

    if (state.funds.isEmpty) {
      return EmptyWidget(
        message: '暂无基金',
        actionLabel: '刷新',
        onAction: () => ref.read(fundListProvider.notifier).loadFunds(),
        icon: Icons.account_balance,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(fundListProvider.notifier).loadFunds(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.funds.length,
        itemBuilder: (context, index) {
          final fund = state.funds[index];
          return FundCard(
            fund: fund,
            onTap: () => _showFundDetail(fund),
          );
        },
      ),
    );
  }

  void _showFundDetail(Fund fund) {
    ref.read(selectedFundProvider.notifier).state = fund;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FundDetailSheet(fund: fund),
    );
  }
}

class _FundDetailSheet extends ConsumerWidget {
  final Fund fund;

  const _FundDetailSheet({required this.fund});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fund Name
              Text(
                fund.fundName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Code and Type
              Text(
                '${fund.fundCode} | ${fund.fundTypeName}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // NAV Info
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: '单位净值',
                      value: '¥${fund.nav}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: '累计净值',
                      value: fund.accNav,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: '风险等级',
                      value: fund.riskLevel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: '起购金额',
                      value: '¥${fund.minPurchase}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              if (fund.description != null) ...[
                const Text(
                  '基金简介',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  fund.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],

              // Company
              if (fund.companyName != null) ...[
                const Text(
                  '基金公司',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  fund.companyName!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],

              // Manager
              if (fund.managerName != null) ...[
                const Text(
                  '基金经理',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  fund.managerName!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],

              // Fee Info
              const Text(
                '费率信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('申购费率: ${fund.purchaseFee}')),
                  Expanded(child: Text('赎回费率: ${fund.redeemFee}')),
                ],
              ),
              const SizedBox(height: 32),

              // Buy Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleBuy(context, ref, fund),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('立即购买'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBuy(BuildContext context, WidgetRef ref, Fund fund) async {
    final result = await AccountGuard.verify(
      ref: ref,
      context: context,
      requiredRiskLevel: _mapRiskLevel(fund.riskLevel),
    );
    if (!context.mounted) return;

    switch (result) {
      case AccountVerificationResult.verified:
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买 ${fund.fundName}')),
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

  String? _mapRiskLevel(String? level) {
    // Map fund risk level to account guard risk level
    // e.g., "中风险" -> "C3"
    final mapping = {
      '低风险': 'C1',
      '中低风险': 'C2',
      '中风险': 'C3',
      '中高风险': 'C4',
      '高风险': 'C5',
    };
    return mapping[level];
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

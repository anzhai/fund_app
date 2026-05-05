import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(accountProvider.notifier).loadBankCards();
      ref.read(accountProvider.notifier).loadRiskAssessment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? AppErrorWidget(message: state.error!)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRiskSection(state.riskAssessment),
                      const SizedBox(height: 24),
                      _buildBankCardsSection(state.bankCards),
                      const SizedBox(height: 24),
                      _buildAccountOpensSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRiskSection(RiskAssessment? assessment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('风险评估', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (assessment == null || assessment.isExpired)
                  TextButton(
                    onPressed: () => context.go('/account/risk-assessment'),
                    child: const Text('去评估'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (assessment == null)
              const Text('未评估', style: TextStyle(color: Colors.grey))
            else
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(assessment.levelName, style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Text('有效期至 ${_formatDate(assessment.expiresAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCardsSection(List<BankCard> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('银行卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCardDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (cards.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('暂未绑定银行卡'))))
        else
          Card(
            child: Column(
              children: cards.map((card) => _BankCardItem(card: card, onDelete: () => _deleteCard(card.id))).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountOpensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('开户记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('基金账户'),
            subtitle: const Text('点击申请开户'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showOpenAccountDialog(),
          ),
        ),
      ],
    );
  }

  void _showAddCardDialog() {
    final bankCodeController = TextEditingController();
    final cardNoController = TextEditingController();
    String cardType = '储蓄卡';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加银行卡'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCodeController,
                decoration: const InputDecoration(labelText: '银行代码', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cardNoController,
                decoration: const InputDecoration(labelText: '卡号', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cardType,
                decoration: const InputDecoration(labelText: '卡类型', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '储蓄卡', child: Text('储蓄卡')),
                  DropdownMenuItem(value: '信用卡', child: Text('信用卡')),
                ],
                onChanged: (value) => setState(() => cardType = value ?? '储蓄卡'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                if (bankCodeController.text.isNotEmpty && cardNoController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await ref.read(accountProvider.notifier).addBankCard(
                    bankCode: bankCodeController.text,
                    cardNo: cardNoController.text,
                    cardType: cardType,
                  );
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCard(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除银行卡'),
        content: const Text('确定要删除这张银行卡吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountProvider.notifier).deleteBankCard(id);
    }
  }

  void _showOpenAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('基金开户'),
        content: const Text('是否申请开通基金账户？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await ref.read(accountProvider.notifier).openAccount(type: 'fund');
              if (success && mounted) {
                messenger.showSnackBar(const SnackBar(content: Text('开户申请已提交')));
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _BankCardItem extends StatelessWidget {
  final BankCard card;
  final VoidCallback onDelete;

  const _BankCardItem({required this.card, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        child: Text(card.bankName[0], style: TextStyle(color: Colors.blue[700])),
      ),
      title: Text(card.bankName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${card.cardType} ${card.maskedCardNo}'),
      trailing: card.isDefault
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
              child: Text('默认', style: TextStyle(color: Colors.green[700], fontSize: 12)),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
    );
  }
}
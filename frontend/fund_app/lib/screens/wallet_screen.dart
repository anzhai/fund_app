import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _wallet;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ApiService().getWallet();
      final transactions = await ApiService().getWalletTransactions();
      setState(() {
        _wallet = wallet;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRechargeDialog() async {
    final amountController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('充值'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '充值金额',
            prefixText: '¥ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效金额')),
                );
                return;
              }
              
              try {
                await ApiService().recharge(amount: amount);
                if (mounted) {
                  Navigator.pop(context);
                  _loadWallet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('充值成功')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('充值失败: $e')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawDialog() async {
    final amountController = TextEditingController();
    String withdrawType = 'normal';
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('取现'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '取现金额',
                  prefixText: '¥ ',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: withdrawType,
                decoration: const InputDecoration(labelText: '取现方式'),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('普通取现 (T+1到账)')),
                  DropdownMenuItem(value: 'fast', child: Text('快速取现 (实时到账，限额1万)')),
                ],
                onChanged: (value) => setState(() => withdrawType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效金额')),
                  );
                  return;
                }
                
                try {
                  await ApiService().withdraw(amount: amount, withdrawType: withdrawType);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadWallet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('取现申请成功')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('取现失败: $e')),
                  );
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('钱包')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('钱包')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('钱包余额', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '¥${_wallet?['balance'] ?? '0.00'}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showRechargeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('充值'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showWithdrawDialog,
                          icon: const Icon(Icons.remove),
                          label: const Text('取现'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction History
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('交易记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_transactions.isEmpty)
                    const Center(child: Text('暂无交易记录'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final isIncome = tx['transaction_type'] == 'recharge' || tx['transaction_type'] == 'redeem';
                        return ListTile(
                          leading: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(_getTransactionTypeName(tx['transaction_type'])),
                          subtitle: Text(tx['created_at'].toString().substring(0, 19)),
                          trailing: Text(
                            '${isIncome ? "+" : "-"}¥${tx['amount']}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'recharge': return '充值';
      case 'withdraw': return '取现';
      case 'purchase': return '购买基金';
      case 'redeem': return '赎回基金';
      default: return type;
    }
  }
}

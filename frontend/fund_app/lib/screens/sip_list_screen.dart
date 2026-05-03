import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SIPListScreen extends StatefulWidget {
  const SIPListScreen({super.key});

  @override
  State<SIPListScreen> createState() => _SIPListScreenState();
}

class _SIPListScreenState extends State<SIPListScreen> {
  List<dynamic> _sipPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSIPPlans();
  }

  Future<void> _loadSIPPlans() async {
    try {
      final plans = await ApiService().getSIPPlans();
      setState(() {
        _sipPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateSIPDialog() async {
    final fundCodeController = TextEditingController(text: '000001');
    final amountController = TextEditingController();
    String frequency = 'monthly';
    int dayOfPeriod = 1;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建定投计划'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fundCodeController,
                decoration: const InputDecoration(labelText: '基金代码'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '定投金额'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: '定投周期'),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('每周')),
                  DropdownMenuItem(value: 'biweekly', child: Text('每两周')),
                  DropdownMenuItem(value: 'monthly', child: Text('每月')),
                ],
                onChanged: (value) => frequency = value!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: dayOfPeriod,
                decoration: const InputDecoration(labelText: '扣款日'),
                items: List.generate(28, (i) => i + 1)
                    .map((day) => DropdownMenuItem(value: day, child: Text('$day日')))
                    .toList(),
                onChanged: (value) => dayOfPeriod = value!,
              ),
            ],
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
                await ApiService().createSIPPlan(
                  fundCode: fundCodeController.text,
                  amount: amount,
                  frequency: frequency,
                  dayOfPeriod: dayOfPeriod,
                  startDate: DateTime.now(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadSIPPlans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('定投计划创建成功')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('创建失败: $e')),
                );
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的定投'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateSIPDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sipPlans.isEmpty
              ? const Center(child: Text('暂无定投计划，点击右上角创建'))
              : ListView.builder(
                  itemCount: _sipPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _sipPlans[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(plan['fund_name']),
                        subtitle: Text(
                          '${_getFrequencyName(plan['frequency'])} ¥${plan['amount']} | ${plan['status']}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            // TODO: Handle pause/resume/terminate
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'pause', child: Text('暂停')),
                            const PopupMenuItem(value: 'resume', child: Text('恢复')),
                            const PopupMenuItem(value: 'terminate', child: Text('终止')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _getFrequencyName(String frequency) {
    switch (frequency) {
      case 'daily': return '每日';
      case 'weekly': return '每周';
      case 'biweekly': return '每两周';
      case 'monthly': return '每月';
      default: return frequency;
    }
  }
}

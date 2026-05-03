import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '买入'),
            Tab(text: '卖出'),
            Tab(text: '定投'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BuyTab(),
          SellTab(),
          SIPTab(),
        ],
      ),
    );
  }
}

class BuyTab extends StatefulWidget {
  const BuyTab({Key? key}) : super(key: key);

  @override
  State<BuyTab> createState() => _BuyTabState();
}

class _BuyTabState extends State<BuyTab> {
  final _formKey = GlobalKey<FormState>();
  final _fundCodeController = TextEditingController();
  final _amountController = TextEditingController();
  String _payMethod = 'wallet';
  bool _isLoading = false;

  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService().purchase(
        fundCode: _fundCodeController.text,
        amount: double.parse(_amountController.text),
        payMethod: _payMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('购买成功')),
        );
        _fundCodeController.clear();
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fundCodeController,
              decoration: const InputDecoration(
                labelText: '基金代码',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入基金代码';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '购买金额',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入金额';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _payMethod,
              decoration: const InputDecoration(
                labelText: '支付方式',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'wallet', child: Text('钱包余额')),
                DropdownMenuItem(value: 'bank_card', child: Text('银行卡')),
              ],
              onChanged: (value) => setState(() => _payMethod = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('确认购买', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class SellTab extends StatefulWidget {
  const SellTab({Key? key}) : super(key: key);

  @override
  State<SellTab> createState() => _SellTabState();
}

class _SellTabState extends State<SellTab> {
  final _formKey = GlobalKey<FormState>();
  final _fundCodeController = TextEditingController();
  final _sharesController = TextEditingController();
  String _redeemTo = 'wallet';
  bool _isLoading = false;

  Future<void> _handleRedeem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService().redeem(
        fundCode: _fundCodeController.text,
        shares: double.parse(_sharesController.text),
        redeemTo: _redeemTo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('赎回成功')),
        );
        _fundCodeController.clear();
        _sharesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('赎回失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fundCodeController,
              decoration: const InputDecoration(
                labelText: '基金代码',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入基金代码';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sharesController,
              decoration: const InputDecoration(
                labelText: '赎回份额',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入份额';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _redeemTo,
              decoration: const InputDecoration(
                labelText: '赎回去向',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'wallet', child: Text('钱包')),
                DropdownMenuItem(value: 'bank_card', child: Text('银行卡')),
              ],
              onChanged: (value) => setState(() => _redeemTo = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRedeem,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('确认赎回', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class SIPTab extends StatefulWidget {
  const SIPTab({Key? key}) : super(key: key);

  @override
  State<SIPTab> createState() => _SIPTabState();
}

class _SIPTabState extends State<SIPTab> {
  List<dynamic> _sipPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSIPPlans();
  }

  Future<void> _loadSIPPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await ApiService().listSIPPlans();
      setState(() => _sipPlans = plans);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _createSIPPlan() {
    Navigator.pushNamed(context, '/create-sip');
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadSIPPlans,
            child: _sipPlans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.repeat, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('暂无定投计划', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('创建定投'),
                          onPressed: _createSIPPlan,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sipPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _sipPlans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('${plan['fund_name']}'),
                          subtitle: Text('每期¥${plan['amount']} - ${plan['frequency']}'),
                          trailing: Chip(
                            label: Text(plan['status'] == 'active' ? '进行中' : '已暂停'),
                            backgroundColor: plan['status'] == 'active' ? Colors.green[100] : Colors.grey[200],
                          ),
                        ),
                      );
                    },
                  ),
          );
  }
}

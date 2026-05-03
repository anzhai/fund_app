import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasePage extends ConsumerStatefulWidget {
  final String fundCode;

  const PurchasePage({super.key, required this.fundCode});

  @override
  ConsumerState<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends ConsumerState<PurchasePage> {
  final _amountController = TextEditingController();
  String _payMethod = 'wallet';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的金额')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      // TODO: Call API
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购买成功')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('购买失败: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('购买基金')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(child: ListTile(title: Text('基金代码: ${widget.fundCode}'), subtitle: const Text('货币基金A'))),
            const SizedBox(height: 24),
            const Text('购买金额', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _amountController, decoration: const InputDecoration(prefixText: '¥ ', border: OutlineInputBorder(), hintText: '请输入购买金额'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 8),
            Text('最小购买金额: ¥100.00', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 24),
            const Text('支付方式', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioListTile<String>(title: const Text('钱包余额'), subtitle: const Text('¥0.00'), value: 'wallet', groupValue: _payMethod, onChanged: (v) => setState(() => _payMethod = v!)),
            RadioListTile<String>(title: const Text('银行卡'), subtitle: const Text('快捷支付'), value: 'bank_card', groupValue: _payMethod, onChanged: (v) => setState(() => _payMethod = v!)),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(title: const Text('申购费率'), trailing: Text(_payMethod == 'wallet' ? '0.1折' : '4折')),
                  const Divider(),
                  const ListTile(title: Text('预计手续费'), trailing: Text('¥0.00')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _purchase,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('确认购买'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
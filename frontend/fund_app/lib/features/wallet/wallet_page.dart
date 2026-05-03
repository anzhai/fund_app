import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  final _amountController = TextEditingController();
  String _withdrawType = 'normal';

  void _showRechargeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('充值', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _amountController, decoration: const InputDecoration(prefixText: '¥ ', border: OutlineInputBorder(), hintText: '请输入充值金额'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('充值成功'))); },
                child: const Text('确认充值'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('取现', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _amountController, decoration: const InputDecoration(prefixText: '¥ ', border: OutlineInputBorder(), hintText: '请输入取现金额'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            const Text('取现方式'),
            RadioListTile<String>(title: const Text('普通取现 (T+1到账)'), value: 'normal', groupValue: _withdrawType, onChanged: (v) => setState(() => _withdrawType = v!)),
            RadioListTile<String>(title: const Text('快速取现 (实时到账，有限额)'), value: 'fast', groupValue: _withdrawType, onChanged: (v) => setState(() => _withdrawType = v!)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('取现申请成功'))); },
                child: const Text('确认取现'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('钱包')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.blue,
            child: const Column(
              children: [
                Text('钱包余额', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('¥0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: ElevatedButton.icon(onPressed: _showRechargeDialog, icon: const Icon(Icons.add), label: const Text('充值'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton.icon(onPressed: _showWithdrawDialog, icon: const Icon(Icons.remove), label: const Text('取现'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
              ],
            ),
          ),
          const ListTile(title: Text('交易记录'), trailing: Icon(Icons.chevron_right)),
          const Divider(),
          const Expanded(child: Center(child: Text('暂无交易记录'))),
        ],
      ),
    );
  }
}
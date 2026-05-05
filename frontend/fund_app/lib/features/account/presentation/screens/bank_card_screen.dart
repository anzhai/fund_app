import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/account_provider.dart';

class BankCardScreen extends ConsumerStatefulWidget {
  const BankCardScreen({super.key});

  @override
  ConsumerState<BankCardScreen> createState() => _BankCardScreenState();
}

class _BankCardScreenState extends ConsumerState<BankCardScreen> {
  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _cardNoController = TextEditingController();
  String _cardType = '储蓄卡';
  bool _isDefault = false;

  String? _bankNameError;
  String? _bankCodeError;
  String? _cardNoError;

  final List<Map<String, String>> _bankList = [
    {'name': '中国工商银行', 'code': 'ICBC'},
    {'name': '中国建设银行', 'code': 'CCB'},
    {'name': '中国农业银行', 'code': 'ABC'},
    {'name': '中国银行', 'code': 'BOC'},
    {'name': '招商银行', 'code': 'CMB'},
    {'name': '交通银行', 'code': 'COMM'},
    {'name': '浦发银行', 'code': 'SPDB'},
    {'name': '兴业银行', 'code': 'CIB'},
  ];

  bool _validateForm() {
    setState(() {
      _bankNameError = _bankNameController.text.isEmpty ? '请选择银行' : null;
      _bankCodeError = _bankCodeController.text.isEmpty ? '请输入银行代码' : null;
      _cardNoError = _validateCardNo(_cardNoController.text);
    });
    return _bankNameError == null && _bankCodeError == null && _cardNoError == null;
  }

  String? _validateCardNo(String value) {
    if (value.isEmpty) return '请输入银行卡号';
    if (value.length < 16 || value.length > 19) return '银行卡号格式不正确';
    return null;
  }

  Future<void> _addCard() async {
    if (!_validateForm()) return;

    final success = await ref.read(accountProvider.notifier).addBankCard(
      bankCode: _bankCodeController.text,
      cardNo: _cardNoController.text,
      cardType: _cardType,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('银行卡添加成功')),
      );
      _clearForm();
    }
  }

  void _clearForm() {
    _bankNameController.clear();
    _bankCodeController.clear();
    _cardNoController.clear();
    setState(() {
      _cardType = '储蓄卡';
      _isDefault = false;
    });
  }

  Future<void> _deleteCard(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除银行卡'),
        content: const Text('确定要删除这张银行卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(accountProvider.notifier).deleteBankCard(id);
    }
  }

  void _showBankSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _bankList.length,
        itemBuilder: (context, index) {
          final bank = _bankList[index];
          return ListTile(
            title: Text(bank['name']!),
            onTap: () {
              setState(() {
                _bankNameController.text = bank['name']!;
                _bankCodeController.text = bank['code']!;
              });
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('银行卡管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('添加银行卡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _showBankSelector,
                        child: TextFormField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            labelText: '选择银行',
                            prefixIcon: const Icon(Icons.account_balance),
                            border: const OutlineInputBorder(),
                            errorText: _bankNameError,
                          ),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardNoController,
                        decoration: InputDecoration(
                          labelText: '银行卡号',
                          hintText: '请输入16-19位银行卡号',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: const OutlineInputBorder(),
                          errorText: _cardNoError,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          if (_cardNoError != null) {
                            setState(() => _cardNoError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('卡片类型：'),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('储蓄卡'),
                            selected: _cardType == '储蓄卡',
                            onSelected: (selected) {
                              if (selected) setState(() => _cardType = '储蓄卡');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('信用卡'),
                            selected: _cardType == '信用卡',
                            onSelected: (selected) {
                              if (selected) setState(() => _cardType = '信用卡');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('设为默认卡'),
                        value: _isDefault,
                        onChanged: (value) => setState(() => _isDefault = value ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addCard,
                          child: const Text('添加银行卡'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('我的银行卡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${state.bankCards.length} 张', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Expanded(
                  child: state.bankCards.isEmpty
                      ? Center(
                          child: Text(
                            '暂无银行卡',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.bankCards.length,
                          itemBuilder: (context, index) {
                            final card = state.bankCards[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.account_balance_wallet),
                                title: Text(card.bankName),
                                subtitle: Text('${card.cardNo.substring(0, 4)}****${card.cardNo.substring(card.cardNo.length - 4)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (card.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('默认', style: TextStyle(fontSize: 12)),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCard(card.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _cardNoController.dispose();
    super.dispose();
  }
}
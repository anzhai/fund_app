import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AccountOpenScreen extends StatefulWidget {
  const AccountOpenScreen({super.key});

  @override
  State<AccountOpenScreen> createState() => _AccountOpenScreenState();
}

class _AccountOpenScreenState extends State<AccountOpenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCardController = TextEditingController();
  final _nameController = TextEditingController();
  final _tradePasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  DateTime? _expireDate;
  bool _isLoading = false;

  Future<void> _selectExpireDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365 * 10)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    );
    if (date != null) {
      setState(() => _expireDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_expireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择身份证有效期')),
      );
      return;
    }

    if (_tradePasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次密码输入不一致')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService().openAccount(
        idCard: _idCardController.text.trim(),
        realName: _nameController.text.trim(),
        idCardExpire: DateFormat('yyyy-MM-dd').format(_expireDate!),
        tradePassword: _tradePasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('开户成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开户失败: $e')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('开户')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('证件信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _idCardController,
                        decoration: const InputDecoration(
                          labelText: '身份证号',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入身份证号';
                          }
                          if (value.length != 18) {
                            return '身份证号格式不正确';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '真实姓名',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入真实姓名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectExpireDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '身份证有效期',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _expireDate == null
                                ? '请选择'
                                : DateFormat('yyyy-MM-dd').format(_expireDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('交易密码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('• 6位数字\n• 不能为连续或重复数字\n• 不能为身份证或手机号后6位',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tradePasswordController,
                        obscureText: true,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '交易密码',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入交易密码';
                          }
                          if (value.length != 6) {
                            return '交易密码必须为6位';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '确认交易密码',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认交易密码';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('提交开户', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idCardController.dispose();
    _nameController.dispose();
    _tradePasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

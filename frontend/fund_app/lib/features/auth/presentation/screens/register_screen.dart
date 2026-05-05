import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smsCodeController = TextEditingController();
  bool _obscurePassword = true;
  bool _countingDown = false;
  int _countdownSeconds = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册账户'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      hintText: '请输入手机号',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _smsCodeController,
                          decoration: const InputDecoration(
                            labelText: '验证码',
                            hintText: '请输入验证码',
                            prefixIcon: Icon(Icons.sms),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: OutlinedButton(
                          onPressed: _countingDown ? null : _sendSmsCode,
                          child: Text(_countingDown ? '$_countdownSeconds秒' : '获取验证码'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入密码（8位以上）',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Text(state.error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('注册', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('已有账户？'),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('登录'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号')),
      );
      return;
    }

    await ref.read(authProvider.notifier).sendSmsCode(phone);

    setState(() {
      _countingDown = true;
      _countdownSeconds = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdownSeconds--);
      if (_countdownSeconds <= 0) {
        setState(() => _countingDown = false);
        return false;
      }
      return true;
    });
  }

  Future<void> _register() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final smsCode = _smsCodeController.text.trim();

    if (phone.isEmpty || password.isEmpty || smsCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有字段')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码长度至少8位')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
      phone: phone,
      password: password,
      smsCode: smsCode,
    );

    if (success && mounted) {
      context.go('/');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _phoneError = Validators.validatePhone(_phoneController.text.trim());
      _passwordError = Validators.validatePassword(_passwordController.text);
    });
    return _phoneError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: state.isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.account_balance, size: 64, color: Colors.blue),
                      const SizedBox(height: 24),
                      const Text(
                        '基金组合管理',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '登录您的账户',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: '手机号',
                          hintText: '请输入11位手机号',
                          prefixIcon: const Icon(Icons.phone),
                          border: const OutlineInputBorder(),
                          errorText: _phoneError,
                          counterText: '${_phoneController.text.length}/11',
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        onChanged: (value) {
                          if (_phoneError != null) {
                            setState(() {
                              _phoneError = Validators.validatePhone(value.trim());
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '密码',
                          hintText: '请输入密码（6-20位，包含字母和数字）',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = Validators.validatePassword(value);
                            });
                          }
                        },
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.error!,
                                  style: TextStyle(color: Colors.red[700], fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('登录', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('注册账户'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('忘记密码？'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(
      phone: phone,
      password: password,
    );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isUserNotFound) {
      // 用户不存在，跳转到注册页面
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该手机号未注册，请先注册')),
      );
      context.go('/register');
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录成功')),
      );
      context.go('/');
    }
  }
}
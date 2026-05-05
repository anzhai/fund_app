import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _countingDown = false;
  int _countdownSeconds = 0;
  
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _smsCodeError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  bool _canSendSmsCode() {
    final phone = _phoneController.text.trim();
    return phone.length == 11 && Validators.validatePhone(phone) == null && !_countingDown;
  }

  bool _validateForm() {
    setState(() {
      _phoneError = Validators.validatePhone(_phoneController.text.trim());
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError = Validators.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
      _smsCodeError = Validators.validateSmsCode(_smsCodeController.text.trim());
    });
    return _phoneError == null && 
           _passwordError == null && 
           _confirmPasswordError == null && 
           _smsCodeError == null;
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _smsCodeController,
                            decoration: InputDecoration(
                              labelText: '验证码',
                              hintText: '请输入6位验证码',
                              prefixIcon: const Icon(Icons.sms),
                              border: const OutlineInputBorder(),
                              errorText: _smsCodeError,
                              counterText: '${_smsCodeController.text.length}/6',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onChanged: (value) {
                              if (_smsCodeError != null) {
                                setState(() {
                                  _smsCodeError = Validators.validateSmsCode(value.trim());
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: _canSendSmsCode() ? _sendSmsCode : null,
                            child: Text(_countingDown ? '$_countdownSeconds秒' : '获取验证码'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '6-20位，包含字母和数字',
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
                        if (_passwordError != null || _confirmPasswordController.text.isNotEmpty) {
                          setState(() {
                            _passwordError = Validators.validatePassword(value);
                            if (_confirmPasswordController.text.isNotEmpty) {
                              _confirmPasswordError = Validators.validateConfirmPassword(
                                _confirmPasswordController.text,
                                value,
                              );
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: '确认密码',
                        hintText: '请再次输入密码',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        errorText: _confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      onChanged: (value) {
                        if (_confirmPasswordError != null) {
                          setState(() {
                            _confirmPasswordError = Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            );
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
                      onPressed: _validateForm() ? _register : null,
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
            ),
    );
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();

    if (!_validateForm() || _phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号')),
      );
      return;
    }

    await ref.read(authProvider.notifier).sendSmsCode(phone);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('验证码已发送（测试环境请使用 888888）')),
    );

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
    if (!_validateForm()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final smsCode = _smsCodeController.text.trim();

    final success = await ref.read(authProvider.notifier).register(
      phone: phone,
      password: password,
      smsCode: smsCode,
    );

    if (!mounted) return;

    if (success) {
      // 注册成功，跳转到注册成功页面
      context.go('/register-success');
    } else {
      // 显示错误信息
      final authState = ref.read(authProvider);
      if (authState.error?.contains('已存在') == true ||
          authState.error?.contains('已注册') == true ||
          authState.error?.contains('duplicate') == true) {
        // 账号已存在，跳转到登录页面
        context.go('/login');
      }
    }
  }
}

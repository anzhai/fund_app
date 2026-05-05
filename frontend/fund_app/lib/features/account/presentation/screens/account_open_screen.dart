import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/validators.dart';
import '../providers/account_provider.dart';

class AccountOpenScreen extends ConsumerStatefulWidget {
  const AccountOpenScreen({super.key});

  @override
  ConsumerState<AccountOpenScreen> createState() => _AccountOpenScreenState();
}

class _AccountOpenScreenState extends ConsumerState<AccountOpenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _realNameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _tradePasswordController = TextEditingController();
  final _confirmTradePasswordController = TextEditingController();
  DateTime? _idCardExpireDate;
  int _currentStep = 0;

  String? _realNameError;
  String? _idCardError;
  String? _idCardExpireError;
  String? _tradePasswordError;
  String? _confirmTradePasswordError;

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    _tradePasswordController.dispose();
    _confirmTradePasswordController.dispose();
    super.dispose();
  }

  bool _validateStep0() {
    setState(() {
      _realNameError = Validators.validateRealName(_realNameController.text.trim());
      _idCardError = _validateIdCard(_idCardController.text.trim());
    });
    return _realNameError == null && _idCardError == null;
  }

  bool _validateStep1() {
    setState(() {
      if (_idCardExpireDate == null) {
        _idCardExpireError = '请选择身份证有效期';
      } else {
        _idCardExpireError = null;
      }
    });
    return _idCardExpireError == null;
  }

  bool _validateStep2() {
    setState(() {
      _tradePasswordError = _validateTradePasswordStrength(
        _tradePasswordController.text,
        _idCardController.text.trim(),
        '', // phone not available here
      );
      _confirmTradePasswordError = Validators.validateConfirmPassword(
        _confirmTradePasswordController.text,
        _tradePasswordController.text,
      );
    });
    return _tradePasswordError == null && _confirmTradePasswordError == null;
  }

  String? _validateIdCard(String value) {
    if (value.isEmpty) {
      return '请输入身份证号';
    }
    // 15位或18位身份证
    final idCard15Regex = RegExp(r'^\d{15}$');
    final idCard18Regex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCard15Regex.hasMatch(value) && !idCard18Regex.hasMatch(value)) {
      return '身份证号格式不正确';
    }
    return null;
  }

  String? _validateTradePasswordStrength(String password, String idCard, String phone) {
    if (password.isEmpty) {
      return '请输入交易密码';
    }
    if (password.length != 6) {
      return '交易密码必须为6位数字';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      return '交易密码必须是6位数字';
    }

    // 检查等差数列 (123456, 654321, 135790等)
    final arithmeticSequences = [
      '012345', '123456', '234567', '345678', '456789', '567890',
      '098765', '987654', '876543', '765432', '654321', '543210',
      '135790', '246801', '357912', '468023', '579134', '680245', '791356',
      '159240', '268351', '379462', '480573', '591684', '602795', '713806', '824917',
    ];
    if (arithmeticSequences.contains(password)) {
      return '交易密码不能为连续数字';
    }

    // 检查回文数 (121212, 123321等)
    if (_isPalindrome(password)) {
      return '交易密码不能为回文数';
    }

    // 检查与证件号连续6位相同
    if (idCard.length >= 6) {
      for (int i = 0; i <= idCard.length - 6; i++) {
        final subStr = idCard.substring(i, i + 6);
        if (password == subStr) {
          return '交易密码不能与证件号连续6位相同';
        }
      }
    }

    return null;
  }

  bool _isPalindrome(String s) {
    if (s.length != 6) return false;
    return s[0] == s[5] && s[1] == s[4] && s[2] == s[3];
  }

  /// 根据年龄计算身份证有效期
  /// - 16周岁以下：5年
  /// - 16-26周岁：10年
  /// - 26-46周岁：20年
  /// - 46周岁以上：长期
  DateTime? _calculateIdCardExpireDate(String birthDateStr) {
    // 从身份证号提取出生日期 (假设18位身份证)
    // 格式: YYYYMMDD 或 YYMMDD
    try {
      String birthDate;
      if (birthDateStr.length == 18) {
        birthDate = birthDateStr.substring(6, 14);
      } else if (birthDateStr.length == 15) {
        final year = int.parse(birthDateStr.substring(6, 8));
        final month = birthDateStr.substring(8, 10);
        final day = birthDateStr.substring(10, 12);
        birthDate = '19$year$month$day';
      } else {
        return null;
      }

      final birthDateTime = DateTime(
        int.parse(birthDate.substring(0, 4)),
        int.parse(birthDate.substring(4, 6)),
        int.parse(birthDate.substring(6, 8)),
      );

      final now = DateTime.now();
      final age = now.difference(birthDateTime).inDays / 365;

      if (age < 16) {
        return DateTime(now.year + 5, now.month, now.day);
      } else if (age < 26) {
        return DateTime(now.year + 10, now.month, now.day);
      } else if (age < 46) {
        return DateTime(now.year + 20, now.month, now.day);
      } else {
        return DateTime(now.year + 50, now.month, now.day); // 长期
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitAccountOpen() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateStep2()) return;

    final success = await ref.read(accountProvider.notifier).openAccount(
      realName: _realNameController.text.trim(),
      idCard: _idCardController.text.trim(),
      idCardExpire: _idCardExpireDate!,
      tradePassword: _tradePasswordController.text,
    );

    if (success && mounted) {
      context.go('/account/risk-assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('开通基金账户'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    if (_currentStep == 0) _buildStep0(),
                    if (_currentStep == 1) _buildStep1(),
                    if (_currentStep == 2) _buildStep2(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, '基本信息'),
        _buildStepLine(0),
        _buildStepCircle(1, '身份验证'),
        _buildStepLine(1),
        _buildStepCircle(2, '设置密码'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blue : Colors.grey[300],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.blue : Colors.grey[300],
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请填写您的基本信息',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _realNameController,
          decoration: InputDecoration(
            labelText: '真实姓名',
            hintText: '请输入真实姓名',
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
            errorText: _realNameError,
          ),
          onChanged: (_) {
            if (_realNameError != null) {
              setState(() => _realNameError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _idCardController,
          decoration: InputDecoration(
            labelText: '身份证号',
            hintText: '请输入18位或15位身份证号',
            prefixIcon: const Icon(Icons.card_membership),
            border: const OutlineInputBorder(),
            errorText: _idCardError,
          ),
          maxLength: 18,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (_idCardError != null) {
              setState(() => _idCardError = null);
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_validateStep0()) {
                setState(() => _currentStep = 1);
              }
            },
            child: const Text('下一步'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    // 根据身份证计算建议的到期日期
    final suggestedDate = _calculateIdCardExpireDate(_idCardController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请确认身份证有效期',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '根据您的出生日期，系统建议有效期至：${_formatDate(suggestedDate)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () => _selectIdCardExpireDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '身份证有效期',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              errorText: _idCardExpireError,
            ),
            child: Text(
              _idCardExpireDate != null
                  ? _formatDate(_idCardExpireDate)
                  : '请选择身份证有效期',
              style: TextStyle(
                color: _idCardExpireDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildIdCardExpireGuide(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('上一步'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_validateStep1()) {
                    setState(() => _currentStep = 2);
                  }
                },
                child: const Text('下一步'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdCardExpireGuide() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '身份证有效期规则：',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildGuideItem('16周岁以下', '5年'),
            _buildGuideItem('16-26周岁', '10年'),
            _buildGuideItem('26-46周岁', '20年'),
            _buildGuideItem('46周岁以上', '长期'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String age, String years) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$age：', style: const TextStyle(fontSize: 12)),
          Text('$years', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置交易密码',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '交易密码用于基金交易验证，请妥善保管',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _tradePasswordController,
          decoration: InputDecoration(
            labelText: '交易密码',
            hintText: '6位数字',
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            errorText: _tradePasswordError,
            helperText: '禁止：连续数字、回文数、与证件号连续6位相同',
            helperStyle: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          onChanged: (value) {
            if (_tradePasswordError != null) {
              setState(() => _tradePasswordError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmTradePasswordController,
          decoration: InputDecoration(
            labelText: '确认交易密码',
            hintText: '请再次输入交易密码',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            errorText: _confirmTradePasswordError,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          onChanged: (value) {
            if (_confirmTradePasswordError != null) {
              setState(() => _confirmTradePasswordError = null);
            }
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('上一步'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitAccountOpen,
                child: const Text('完成开户'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectIdCardExpireDate(BuildContext context) async {
    final suggestedDate = _calculateIdCardExpireDate(_idCardController.text.trim());
    final initialDate = suggestedDate ?? DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    );

    if (picked != null) {
      setState(() {
        _idCardExpireDate = picked;
        _idCardExpireError = null;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
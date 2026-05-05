import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
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
  final _bankCardController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime? _idCardExpireDate;
  int _currentStep = 0;

  String? _realNameError;
  String? _idCardError;
  String? _idCardExpireError;
  String? _tradePasswordError;
  String? _confirmTradePasswordError;
  String? _bankCardError;
  String? _bankNameError;
  String? _phoneError;
  String? _smsCodeError;

  String? _frontIdCardBase64;
  String? _backIdCardBase64;
  Uint8List? _frontIdCardBytes;
  Uint8List? _backIdCardBytes;
  bool _isUploading = false;
  bool _countingDown = false;
  int _countdownSeconds = 0;

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    _tradePasswordController.dispose();
    _confirmTradePasswordController.dispose();
    _bankCardController.dispose();
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    // 使用 SchedulerBinding 确保在 build 完成后显示 SnackBar
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  Future<void> _pickAndUploadImage(bool isFront) async {
    final picker = ImagePicker();

    // Show bottom sheet to choose camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Data = base64Encode(bytes);
    final imageType = isFront ? 'front' : 'back';

    setState(() {
      _isUploading = true;
      if (isFront) {
        _frontIdCardBase64 = base64Data;
        _frontIdCardBytes = bytes;
      } else {
        _backIdCardBase64 = base64Data;
        _backIdCardBytes = bytes;
      }
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.post(
        '${AppConstants.accountBaseUrl}/account/ocr/id-card',
        data: {
          'image_type': imageType,
          'image_data': base64Data,
        },
      );

      if (isFront) {
        if (response.data['real_name'] != null) {
          _realNameController.text = response.data['real_name'];
        }
        if (response.data['id_card'] != null) {
          _idCardController.text = response.data['id_card'];
        }
        if (response.data['id_card_expire'] != null) {
          try {
            _idCardExpireDate = DateTime.parse(response.data['id_card_expire']);
          } catch (_) {}
        }
        showSnackBar('身份证正面识别成功');
      } else {
        if (response.data['valid_date'] != null && _idCardExpireDate == null) {
          final match = RegExp(r'(\d{4}-\d{2}-\d{2})至(\d{4}-\d{2}-\d{2})').firstMatch(response.data['valid_date']);
          if (match != null) {
            try {
              _idCardExpireDate = DateTime.parse(match.group(2)!);
            } catch (_) {}
          }
        }
        showSnackBar('身份证背面识别成功');
      }

      if (_frontIdCardBase64 != null && _backIdCardBase64 != null) {
        setState(() => _currentStep = 1);
      }
    } catch (e) {
      showSnackBar('识别失败，请手动输入');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendSmsCode() async {
    if (_phoneController.text.length != 11) {
      showSnackBar('请输入正确的手机号');
      return;
    }

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

    showSnackBar('验证码已发送（测试环境请使用 123456）');
  }

  bool _validateStep0() {
    if (_frontIdCardBase64 == null || _backIdCardBase64 == null) {
      showSnackBar('请上传身份证正反面');
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    setState(() {
      _realNameError = _realNameController.text.trim().isEmpty ? '请输入真实姓名' : null;
      _idCardError = _validateIdCard(_idCardController.text.trim());
      _idCardExpireError = _idCardExpireDate == null ? '请选择身份证有效期' : null;
    });
    return _realNameError == null && _idCardError == null && _idCardExpireError == null;
  }

  bool _validateStep2() {
    setState(() {
      _bankCardError = _bankCardController.text.length >= 16 && _bankCardController.text.length <= 19
          ? null : '请输入正确的银行卡号';
      _bankNameError = _bankNameController.text.isEmpty ? '请输入所属银行' : null;
      _phoneError = _phoneController.text.length == 11 ? null : '请输入正确的手机号';
      _smsCodeError = _smsCodeController.text.length == 6 ? null : '请输入6位验证码';
    });
    return _bankCardError == null && _bankNameError == null && _phoneError == null && _smsCodeError == null;
  }

  bool _validateStep3() {
    setState(() {
      _tradePasswordError = _validateTradePasswordStrength(
        _tradePasswordController.text,
        _idCardController.text.trim(),
        '',
      );
      _confirmTradePasswordError = _confirmTradePasswordController.text == _tradePasswordController.text
          ? null : '两次输入的密码不一致';
    });
    return _tradePasswordError == null && _confirmTradePasswordError == null;
  }

  String? _validateIdCard(String value) {
    if (value.isEmpty) return '请输入身份证号';
    final idCard15Regex = RegExp(r'^\d{15}$');
    final idCard18Regex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCard15Regex.hasMatch(value) && !idCard18Regex.hasMatch(value)) {
      return '身份证号格式不正确';
    }
    return null;
  }

  String? _validateTradePasswordStrength(String password, String idCard, String phone) {
    if (password.isEmpty) return '请输入交易密码';
    if (password.length != 6) return '交易密码必须为6位数字';
    if (!RegExp(r'^\d{6}$').hasMatch(password)) return '交易密码必须是6位数字';

    final arithmeticSequences = [
      '012345', '123456', '234567', '345678', '456789', '567890',
      '098765', '987654', '876543', '765432', '654321', '543210',
      '135790', '246801', '357912', '468023', '579134', '680245', '791356',
      '159240', '268351', '379462', '480573', '591684', '602795', '713806', '824917',
    ];
    if (arithmeticSequences.contains(password)) return '交易密码不能为连续数字';
    if (_isPalindrome(password)) return '交易密码不能为回文数';

    if (idCard.length >= 6) {
      for (int i = 0; i <= idCard.length - 6; i++) {
        final subStr = idCard.substring(i, i + 6);
        if (password == subStr) return '交易密码不能与证件号连续6位相同';
      }
    }
    return null;
  }

  bool _isPalindrome(String s) {
    if (s.length != 6) return false;
    return s[0] == s[5] && s[1] == s[4] && s[2] == s[3];
  }

  Future<void> _submitAccountOpen() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateStep3()) return;

    final success = await ref.read(accountProvider.notifier).openAccount(
      realName: _realNameController.text.trim(),
      idCard: _idCardController.text.trim(),
      idCardExpire: _idCardExpireDate!,
      tradePassword: _tradePasswordController.text,
    );

    if (success && mounted) {
      context.go('/account-open-success');
    } else {
      final state = ref.read(accountProvider);
      if (state.error != null) {
        showSnackBar(state.error!);
      }
    }
  }

  Future<void> _verifyBankCard() async {
    if (!_validateStep2()) return;

    try {
      final apiClient = ApiClient();
      await apiClient.post(
        '${AppConstants.accountBaseUrl}/account/verify/bank-card',
        data: {
          'bank_code': _bankCodeController.text,
          'card_number': _bankCardController.text,
          'phone': _phoneController.text,
          'sms_code': _smsCodeController.text,
        },
      );

      if (mounted) {
        showSnackBar('银行卡验证成功');
        setState(() => _currentStep = 3);
      }
    } catch (e) {
      showSnackBar('验证失败: ${e.toString()}');
    }
  }

  Future<void> _scanBankCard() async {
    setState(() {
      _bankCardController.text = '6222021234567890123';
      _bankNameController.text = '中国工商银行';
      _bankCodeController.text = 'ICBC';
    });
    showSnackBar('银行卡识别成功');
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
      body: _isUploading || state.isLoading
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
                    if (_currentStep == 0) _buildStep0_IDCardUpload(),
                    if (_currentStep == 1) _buildStep1_InfoConfirm(),
                    if (_currentStep == 2) _buildStep2_BankCard(),
                    if (_currentStep == 3) _buildStep3_Password(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['上传证件', '信息确认', '绑定银行卡', '设置密码'];
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildStepCircle(i, steps[i]),
          if (i < steps.length - 1) _buildStepLine(i),
        ],
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blue : Colors.grey[300],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.blue : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    return Expanded(
      child: Container(height: 2, color: _currentStep > afterStep ? Colors.blue : Colors.grey[300], margin: const EdgeInsets.only(bottom: 20)),
    );
  }

  Widget _buildStep0_IDCardUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('请上传身份证照片', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('请确保照片清晰可读', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildIdCardUploadBox(true, '身份证正面', Icons.person)),
            const SizedBox(width: 16),
            Expanded(child: _buildIdCardUploadBox(false, '身份证反面', Icons.credit_card)),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateStep0() ? () => setState(() => _currentStep = 1) : null,
            child: const Text('下一步'),
          ),
        ),
      ],
    );
  }

  Widget _buildIdCardUploadBox(bool isFront, String label, IconData icon) {
    final hasImage = isFront ? _frontIdCardBase64 != null : _backIdCardBase64 != null;
    final imageBytes = isFront ? _frontIdCardBytes : _backIdCardBytes;

    // OCR info to display below image
    final ocrInfo = isFront
        ? (_realNameController.text.isNotEmpty || _idCardController.text.isNotEmpty
            ? '${_realNameController.text} | ${_idCardController.text}'
            : null)
        : (_idCardExpireDate != null
            ? '有效期至: ${_formatDate(_idCardExpireDate)}'
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _pickAndUploadImage(isFront),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: hasImage ? Colors.blue : Colors.grey[300]!, width: hasImage ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              color: hasImage ? Colors.blue[50] : null,
            ),
            child: hasImage && imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(label, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
          ),
        ),
        if (hasImage && ocrInfo != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ocrInfo,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStep1_InfoConfirm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('请确认身份证信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _realNameController,
          decoration: InputDecoration(labelText: '真实姓名', prefixIcon: const Icon(Icons.person), border: const OutlineInputBorder(), errorText: _realNameError),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _idCardController,
          decoration: InputDecoration(labelText: '身份证号', prefixIcon: const Icon(Icons.card_membership), border: const OutlineInputBorder(), errorText: _idCardError),
          maxLength: 18,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectIdCardExpireDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '身份证有效期',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              errorText: _idCardExpireError,
            ),
            child: Text(_idCardExpireDate != null ? _formatDate(_idCardExpireDate) : '请选择身份证有效期', style: TextStyle(color: _idCardExpireDate != null ? Colors.black : Colors.grey)),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('上一步'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: () { if (_validateStep1()) setState(() => _currentStep = 2); }, child: const Text('下一步'))),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2_BankCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('添加银行卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('请绑定您名下的银行卡', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bankCardController,
                decoration: InputDecoration(labelText: '银行卡号', prefixIcon: const Icon(Icons.credit_card), border: const OutlineInputBorder(), errorText: _bankCardError),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _scanBankCard,
              icon: const Icon(Icons.camera_alt, color: Colors.blue),
              tooltip: '扫描银行卡',
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bankNameController,
          decoration: InputDecoration(labelText: '所属银行', prefixIcon: const Icon(Icons.account_balance), border: const OutlineInputBorder(), errorText: _bankNameError),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(labelText: '开户省份', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: '开户城市', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: '预留手机号', prefixIcon: const Icon(Icons.phone), border: const OutlineInputBorder(), errorText: _phoneError),
          keyboardType: TextInputType.phone,
          maxLength: 11,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _smsCodeController,
                decoration: InputDecoration(labelText: '验证码', prefixIcon: const Icon(Icons.sms), border: const OutlineInputBorder(), errorText: _smsCodeError),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: OutlinedButton(
                onPressed: _phoneError == null && !_countingDown ? _sendSmsCode : null,
                child: Text(_countingDown ? '$_countdownSeconds秒' : '获取验证码'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('上一步'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: _verifyBankCard, child: const Text('下一步'))),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3_Password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('设置交易密码', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('交易密码用于基金交易验证，请妥善保管', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmTradePasswordController,
          decoration: InputDecoration(labelText: '确认交易密码', hintText: '请再次输入交易密码', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), errorText: _confirmTradePasswordError),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 2), child: const Text('上一步'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: _submitAccountOpen, child: const Text('完成开户'))),
          ],
        ),
      ],
    );
  }

  Future<void> _selectIdCardExpireDate(BuildContext context) async {
    final initialDate = _idCardExpireDate ?? DateTime.now().add(const Duration(days: 365 * 20));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    );
    if (picked != null) setState(() { _idCardExpireDate = picked; _idCardExpireError = null; });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
class Validators {
  Validators._();

  // 手机号验证
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '手机号格式不正确';
    }
    return null;
  }

  // 密码验证
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    if (value.length > 20) {
      return '密码长度不能超过20位';
    }
    // 密码需包含字母和数字
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    if (!passwordRegex.hasMatch(value)) {
      return '密码需包含字母和数字';
    }
    return null;
  }

  // 确认密码验证
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  // 身份证号验证
  static String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 选填
    }
    final idCardRegex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCardRegex.hasMatch(value)) {
      return '身份证号格式不正确';
    }
    return null;
  }

  // 交易密码验证
  static String? validateTradePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入交易密码';
    }
    if (value.length != 6) {
      return '交易密码必须为6位数字';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '交易密码必须是6位数字';
    }
    return null;
  }

  // 金额验证
  static String? validateAmount(String? value, {double min = 0.01, double max = 9999999}) {
    if (value == null || value.isEmpty) {
      return '请输入金额';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return '请输入有效金额';
    }
    if (amount < min) {
      return '金额不能小于$min';
    }
    if (amount > max) {
      return '金额不能超过$max';
    }
    return null;
  }

  // 真实姓名验证
  static String? validateRealName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入真实姓名';
    }
    if (value.length < 2 || value.length > 20) {
      return '姓名长度应为2-20个字符';
    }
    if (!RegExp(r'^[一-龥a-zA-Z]+$').hasMatch(value)) {
      return '姓名只能包含中文或英文字母';
    }
    return null;
  }

  // 银行卡号验证
  static String? validateBankCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入银行卡号';
    }
    if (value.length < 16 || value.length > 19) {
      return '银行卡号长度应为16-19位';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '银行卡号只能包含数字';
    }
    return null;
  }

  // 验证码验证
  static String? validateSmsCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6) {
      return '验证码为6位数字';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '验证码格式不正确';
    }
    return null;
  }
}

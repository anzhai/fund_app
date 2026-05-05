import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';

/// Account verification result
enum AccountVerificationResult {
  verified,            // 已开户且已完成风险评测，未过期
  needOpenAccount,    // 需要开户
  needRiskAssessment, // 需要风险评测
  riskAssessmentExpired, // 风险评测已过期，需要重新评测
  riskLevelMismatch,  // 风险等级不匹配，不能购买此产品
  notLoggedIn,        // 未登录
}

/// Account status from backend
class AccountStatus {
  final bool hasFundAccount;
  final bool hasRiskAssessment;
  final String? riskLevel;
  final String? riskExpireDate;

  AccountStatus({
    required this.hasFundAccount,
    required this.hasRiskAssessment,
    this.riskLevel,
    this.riskExpireDate,
  });

  factory AccountStatus.fromJson(Map<String, dynamic> json) {
    return AccountStatus(
      hasFundAccount: json['has_fund_account'] as bool? ?? false,
      hasRiskAssessment: json['has_risk_assessment'] as bool? ?? false,
      riskLevel: json['risk_level'] as String?,
      riskExpireDate: json['risk_expire_date'] as String?,
    );
  }

  bool get isRiskAssessmentExpired {
    if (!hasRiskAssessment || riskExpireDate == null) return true;
    try {
      final expireDate = DateTime.parse(riskExpireDate!);
      return DateTime.now().isAfter(expireDate);
    } catch (_) {
      return true;
    }
  }

  String get riskLevelDescription {
    switch (riskLevel) {
      case 'C1': return '保守型';
      case 'C2': return '谨慎型';
      case 'C3': return '稳健型';
      case 'C4': return '积极型';
      case 'C5': return '激进型';
      default: return '未评测';
    }
  }
}

/// Account verification helper
class AccountGuard {
  static final ApiClient _apiClient = ApiClient();

  static Future<AccountStatus?> getAccountStatus() async {
    try {
      final response = await _apiClient.get('${AppConstants.accountBaseUrl}/account/status');
      return AccountStatus.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Check if user can perform operations like recharge, buy funds, etc.
  static Future<AccountVerificationResult> verify({
    required WidgetRef ref,
    required BuildContext context,
    String? requiredRiskLevel, // e.g., 'C3' for medium risk products
  }) async {
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated || authState.user == null) {
      _showLoginPrompt(context);
      return AccountVerificationResult.notLoggedIn;
    }

    AccountStatus? accountStatus;
    try {
      accountStatus = await getAccountStatus();
    } catch (e) {
      // Network or API error - treat as needs verification flow
      accountStatus = null;
    }

    // If we can't get account status, assume not verified and let user go through flow
    if (accountStatus == null) {
      // Show prompt to complete account opening
      if (!context.mounted) return AccountVerificationResult.notLoggedIn;
      final shouldOpen = await _showAccountOpenPrompt(context);
      if (shouldOpen == true && context.mounted) {
        context.push('/account-open');
      }
      return AccountVerificationResult.needOpenAccount;
    }

    // Step 1: Check if account is opened
    if (!accountStatus.hasFundAccount) {
      if (!context.mounted) return AccountVerificationResult.notLoggedIn;
      final shouldOpen = await _showAccountOpenPrompt(context);
      if (shouldOpen == true && context.mounted) {
        context.push('/account-open');
      }
      return AccountVerificationResult.needOpenAccount;
    }

    // Step 2: Check if risk assessment is done
    if (!accountStatus.hasRiskAssessment) {
      if (!context.mounted) return AccountVerificationResult.notLoggedIn;
      final shouldAssess = await _showRiskAssessmentPrompt(context);
      if (shouldAssess == true && context.mounted) {
        context.push('/account/risk-assessment');
      }
      return AccountVerificationResult.needRiskAssessment;
    }

    // Step 3: Check if risk assessment is expired
    if (accountStatus.isRiskAssessmentExpired) {
      if (!context.mounted) return AccountVerificationResult.notLoggedIn;
      final shouldReassess = await _showRiskAssessmentExpiredPrompt(context);
      if (shouldReassess == true && context.mounted) {
        context.push('/account/risk-assessment');
      }
      return AccountVerificationResult.riskAssessmentExpired;
    }

    // Step 4: Check risk level match for specific products
    if (requiredRiskLevel != null && !_isRiskLevelCompatible(accountStatus.riskLevel, requiredRiskLevel)) {
      if (!context.mounted) return AccountVerificationResult.notLoggedIn;
      await _showRiskLevelMismatchDialog(context, accountStatus.riskLevel ?? 'C1', requiredRiskLevel);
      return AccountVerificationResult.riskLevelMismatch;
    }

    return AccountVerificationResult.verified;
  }

  /// Quick check if user is ready to trade (no dialogs)
  static Future<AccountVerificationResult> quickVerify({required WidgetRef ref}) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      return AccountVerificationResult.notLoggedIn;
    }

    final accountStatus = await getAccountStatus();
    if (accountStatus == null) {
      return AccountVerificationResult.notLoggedIn;
    }

    if (!accountStatus.hasFundAccount) {
      return AccountVerificationResult.needOpenAccount;
    }

    if (!accountStatus.hasRiskAssessment || accountStatus.isRiskAssessmentExpired) {
      return AccountVerificationResult.needRiskAssessment;
    }

    return AccountVerificationResult.verified;
  }

  static bool _isRiskLevelCompatible(String? userLevel, String requiredLevel) {
    final levelScores = {'C1': 1, 'C2': 2, 'C3': 3, 'C4': 4, 'C5': 5};
    final userScore = levelScores[userLevel] ?? 0;
    final requiredScore = levelScores[requiredLevel] ?? 0;
    // User can only buy products at or below their risk level
    return userScore >= requiredScore;
  }

  static void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('请先登录'),
        content: const Text('您需要先登录才能进行此操作'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/login');
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showAccountOpenPrompt(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('请先开户'),
        content: const Text('您需要先开通基金账户才能进行此操作'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('去开户'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showRiskAssessmentPrompt(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('请先完成风险评测'),
        content: const Text('根据监管要求，您需要先完成风险评测才能进行基金交易'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('去评测'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showRiskAssessmentExpiredPrompt(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('风险评测已过期'),
        content: const Text('您的风险评测已过期，需要重新评测才能继续交易'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('重新评测'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showRiskLevelMismatchDialog(
    BuildContext context,
    String userLevel,
    String requiredLevel,
  ) async {
    final levelNames = {
      'C1': '保守型',
      'C2': '谨慎型',
      'C3': '稳健型',
      'C4': '积极型',
      'C5': '激进型',
    };
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('风险等级不匹配'),
        content: Text(
          '您的风险等级为${levelNames[userLevel] ?? userLevel}，'
          '该产品需要${levelNames[requiredLevel] ?? requiredLevel}及以上风险等级才能购买',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}
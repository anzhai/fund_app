import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';

/// Account verification result
enum AccountVerificationResult {
  verified,       // 已开户且已完成风险评测
  needOpenAccount, // 需要开户
  needRiskAssessment, // 需要风险评测
  notLoggedIn,     // 未登录
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
}

/// Helper to verify user account status before performing sensitive operations
class AccountGuard {
  static final ApiClient _apiClient = ApiClient();

  /// Check if user can perform operations like recharge, buy funds, etc.
  /// Returns the verification result
  static Future<AccountVerificationResult> verify({
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated || authState.user == null) {
      _showLoginPrompt(context);
      return AccountVerificationResult.notLoggedIn;
    }

    // Get account status from backend
    AccountStatus? accountStatus;
    try {
      accountStatus = await _getAccountStatus();
    } catch (e) {
      // If we can't get account status, assume not verified
      accountStatus = AccountStatus(hasFundAccount: false, hasRiskAssessment: false);
    }

    // Check if account is opened
    if (!accountStatus.hasFundAccount) {
      final shouldOpen = await _showAccountOpenPrompt(context);
      if (shouldOpen == true) {
        return AccountVerificationResult.needOpenAccount;
      }
      return AccountVerificationResult.needOpenAccount;
    }

    // Check if risk assessment is done and not expired
    if (!accountStatus.hasRiskAssessment) {
      final shouldAssess = await _showRiskAssessmentPrompt(context);
      if (shouldAssess == true) {
        return AccountVerificationResult.needRiskAssessment;
      }
      return AccountVerificationResult.needRiskAssessment;
    }

    return AccountVerificationResult.verified;
  }

  static Future<AccountStatus> _getAccountStatus() async {
    final response = await _apiClient.get('${AppConstants.accountBaseUrl}/status');
    return AccountStatus.fromJson(response.data);
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
}
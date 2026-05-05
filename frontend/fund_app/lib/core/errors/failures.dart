/// Base Failure class for domain layer
abstract class Failure {
  final String message;
  final int? code;

  Failure({required this.message, this.code});

  @override
  String toString() => 'Failure: $message (code: $code)';
}

/// Server Failure
class ServerFailure extends Failure {
  ServerFailure({required super.message, super.code});
}

/// Network Failure
class NetworkFailure extends Failure {
  NetworkFailure({required super.message});
}

/// Cache Failure
class CacheFailure extends Failure {
  CacheFailure({required super.message});
}

/// Auth Failure
class AuthFailure extends Failure {
  AuthFailure({required super.message});
}

/// User Not Found Failure - 用户不存在（未注册）
class UserNotFoundFailure extends Failure {
  UserNotFoundFailure({required super.message});
}

/// Account Not Verified Failure - 账户未实名认证
class AccountNotVerifiedFailure extends Failure {
  AccountNotVerifiedFailure({required super.message});
}

/// Validation Failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  ValidationFailure({required super.message, this.fieldErrors});

  @override
  String toString() => 'ValidationFailure: $message, fields: $fieldErrors';
}

/// Unknown Failure
class UnknownFailure extends Failure {
  UnknownFailure({required super.message});
}

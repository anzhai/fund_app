/// Server Exception - API服务器错误
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Network Exception - 网络连接错误
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Cache Exception - 本地缓存错误
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Auth Exception - 认证错误
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Validation Exception - 表单验证错误
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Unknown Exception - 未知错误
class UnknownException implements Exception {
  final String message;

  UnknownException({required this.message});

  @override
  String toString() => 'UnknownException: $message';
}

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<UserModel> login({required String phone, required String password}) async {
    // 后端登录返回TokenResponse
    final response = await _apiClient.post(
      '${AppConstants.authBaseUrl}/login',
      data: {
        'login_type': 'phone',
        'identifier': phone,
        'password': password,
      },
    );

    // 登录成功后，保存token
    final data = response.data;
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    await SecureStorage.saveAccessToken(accessToken);
    await SecureStorage.saveRefreshToken(refreshToken);

    // 然后获取用户信息
    return await getCurrentUser();
  }

  Future<UserModel> register({
    required String phone,
    required String password,
    required String smsCode,
    String? idCard,
  }) async {
    // 后端注册返回TokenResponse
    final response = await _apiClient.post(
      '${AppConstants.authBaseUrl}/register',
      data: {
        'phone': phone,
        'password': password,
        'user_type': 'direct_sales',
      },
    );

    // 注册成功后，保存token
    final data = response.data;
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    await SecureStorage.saveAccessToken(accessToken);
    await SecureStorage.saveRefreshToken(refreshToken);

    // 然后获取用户信息
    return await getCurrentUser();
  }

  Future<void> logout() async {
    await _apiClient.post('${AppConstants.authBaseUrl}/logout');
    await SecureStorage.clearTokens();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('${AppConstants.authBaseUrl}/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> sendSmsCode(String phone) async {
    await _apiClient.post(
      '${AppConstants.authBaseUrl}/sms/send',
      data: {
        'phone': phone,
        'purpose': 'register',
      },
    );
  }
}

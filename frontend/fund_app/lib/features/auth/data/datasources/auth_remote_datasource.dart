import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<UserModel> login({required String phone, required String password}) async {
    final response = await _apiClient.post(
      '${AppConstants.authBaseUrl}/login',
      data: {'phone': phone, 'password': password},
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> register({required String phone, required String password, required String smsCode}) async {
    final response = await _apiClient.post(
      '${AppConstants.authBaseUrl}/register',
      data: {'phone': phone, 'password': password, 'sms_code': smsCode},
    );
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiClient.post('${AppConstants.authBaseUrl}/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('${AppConstants.authBaseUrl}/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> sendSmsCode(String phone) async {
    await _apiClient.post('${AppConstants.authBaseUrl}/sms/send', data: {'phone': phone});
  }
}
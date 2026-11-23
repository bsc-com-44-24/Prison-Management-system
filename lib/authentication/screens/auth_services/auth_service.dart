import '../../../core/api/api_client.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;

  /// Restore the saved bearer token and load the authenticated profile.
  /// Returns null when there is no valid saved session.
  Future<Map<String, dynamic>?> restoreSession() async {
    final api = ApiClient.instance;
    await api.restoreSession();
    if (!api.hasSession) return null;

    try {
      final profileResponse = _asJsonMap(
        await api.get('/auth/me'),
        'User profile response',
      );
      final profile = profileResponse['data'] is Map
          ? Map<String, dynamic>.from(profileResponse['data'] as Map)
          : profileResponse;
      final role = profile['role']?.toString();
      if (role == null || role.trim().isEmpty) {
        throw const ApiException(
          'The API did not return a role for the authenticated user.',
        );
      }
      currentUser = profile;
      return profile;
    } on ApiException {
      await api.clearSession();
      currentUser = null;
      return null;
    }
  }

  Future<void> logout() async {
    currentUser = null;
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // Clear local credentials even when the API cannot be reached.
    } finally {
      await ApiClient.instance.clearSession();
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    await ApiClient.instance.post(
      '/auth/password/forgot',
      body: {'userEmail': email.trim()},
    );
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    await ApiClient.instance.post(
      '/auth/password/reset',
      body: {
        'code': code.trim(),
        'newPassword': newPassword,
      },
    );
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    currentUser = null;
    final api = ApiClient.instance;
    final loginResponse = _asJsonMap(
      await api.post(
        '/auth/login',
        body: {
          'usernameOrEmail': emailOrUsername.trim(),
          'password': password,
        },
      ),
      'Login response',
    );

    final accessToken = loginResponse['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException('The API did not return an access token.');
    }

    await api.saveAccessToken(accessToken);

    try {
      final profileResponse = _asJsonMap(
        await api.get('/auth/me'),
        'User profile response',
      );
      final profile = profileResponse['data'] is Map
          ? Map<String, dynamic>.from(profileResponse['data'] as Map)
          : profileResponse;

      final role = profile['role']?.toString();
      if (role == null || role.trim().isEmpty) {
        throw const ApiException(
          'The API did not return a role for the authenticated user.',
        );
      }

      final user = {
        ...profile,
        'access_token': accessToken,
        'refresh_token': loginResponse['refreshToken'],
      };
      currentUser = user;
      return user;
    } on ApiException {
      await api.clearSession();
      rethrow;
    }
  }

  Map<String, dynamic> _asJsonMap(Object? value, String responseName) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ApiException('$responseName was not a JSON object.');
  }
}

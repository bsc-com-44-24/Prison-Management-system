import '../core/api/api_client.dart';

class DashboardStats {
  final int totalUsers;
  final int registeredPrisons;

  const DashboardStats({
    required this.totalUsers,
    required this.registeredPrisons,
  });
}

class DashboardApiService {
  static Future<int> _getTotalElements(String path) async {
    return ApiClient.instance.getTotalElements(path);
  }

  static Future<int> getTotalUsers() => _getTotalElements('/users');

  static Future<int> getRegisteredPrisons() => _getTotalElements('/prisons');

  static Future<DashboardStats> getDashboardStats() async {
    final results = await Future.wait([
      getTotalUsers(),
      getRegisteredPrisons(),
    ]);

    return DashboardStats(
      totalUsers: results[0],
      registeredPrisons: results[1],
    );
  }
}

class AdminApiService {
  static Future<List<Map<String, dynamic>>> getUsers({
    String? search,
  }) {
    return ApiClient.instance.getAllPages(
      '/users',
      filters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getPrisons() {
    return ApiClient.instance.getAllPages('/prisons');
  }

  static Future<void> createUser({
    required String fullName,
    required String username,
    required String password,
    required String role,
    String? email,
    String? prisonId,
  }) async {
    await ApiClient.instance.post(
      '/users',
      body: {
        'fullName': fullName,
        'username': username,
        'password': password,
        'role': role,
        if (email != null && email.isNotEmpty) 'email': email,
        if (prisonId != null && prisonId.isNotEmpty) 'prisonId': prisonId,
      },
    );
  }

  static Future<void> updateUser({
    required String id,
    required String fullName,
    required String username,
    required String role,
    String? email,
    String? prisonId,
    List<String> permissions = const [],
  }) async {
    await ApiClient.instance.patch(
      '/users/$id',
      body: {
        'fullName': fullName,
        'username': username,
        'role': role,
        'permissions': permissions,
        'email': email,
        'prisonId': prisonId,
      },
    );
  }

  static Future<void> setUserActive({
    required String id,
    required bool active,
  }) async {
    await ApiClient.instance.patch(
      '/users/$id/${active ? 'reactivate' : 'deactivate'}',
    );
  }

  static Future<Map<String, dynamic>> createPrison({
    required String name,
    required String location,
    required String blockName,
    required int firstCellCapacity,
  }) async {
    final response = await ApiClient.instance.post(
      '/prisons',
      body: {
        'name': name,
        'location': location,
        // The backend requires at least one block and one cell on creation.
        'blocks': [
          {
            'name': blockName,
            'cells': [
              {'cellNumber': 1, 'capacity': firstCellCapacity},
            ],
          },
        ],
      },
    );
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException('Unexpected response when creating a prison.');
  }

  static Future<void> updatePrison({
    required String id,
    required String name,
    required String location,
  }) async {
    await ApiClient.instance.patch(
      '/prisons/$id',
      body: {
        'name': name,
        'location': location,
      },
    );
  }
}

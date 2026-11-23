import '../core/api/api_client.dart';

class RosterApiService {
  static Future<List<Map<String, dynamic>>> getRosters() async {
    final result = await ApiClient.instance.get('/rosters');
    if (result is List) {
      return result
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const ApiException('Unexpected duty roster list response.');
  }

  static Future<Map<String, dynamic>> getRoster(String id) async {
    final result = await ApiClient.instance.get('/rosters/$id');
    if (result is Map) return Map<String, dynamic>.from(result);
    throw const ApiException('Unexpected duty roster response.');
  }

  static Future<Map<String, dynamic>> createRoster({
    required String periodStart,
    required String periodEnd,
    String? prisonId,
  }) async {
    final result = await ApiClient.instance.post(
      '/rosters',
      body: {
        if (prisonId != null && prisonId.isNotEmpty) 'prisonId': prisonId,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
      },
    );
    if (result is Map) return Map<String, dynamic>.from(result);
    throw const ApiException('Unexpected response when creating a roster.');
  }

  static Future<void> addShift({
    required String rosterId,
    required String officerId,
    required String startAt,
    required String endAt,
    required String location,
  }) async {
    await ApiClient.instance.post(
      '/rosters/$rosterId/shifts',
      body: {
        'officerId': officerId,
        'startAt': startAt,
        'endAt': endAt,
        'location': location,
      },
    );
  }

  static Future<void> publish(String rosterId) async {
    await ApiClient.instance.post('/rosters/$rosterId/publish');
  }
}

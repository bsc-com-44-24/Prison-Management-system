import '../../core/api/api_client.dart';

class VisitorApiService {
  static Future<List<Map<String, dynamic>>> getVisits({String? visitorName}) {
    return ApiClient.instance.getAllPages(
      '/visits',
      filters: {
        if (visitorName != null && visitorName.trim().isNotEmpty)
          'visitorName': visitorName.trim(),
      },
    );
  }

  static Future<void> recordFamilyVisit({
    required String visitorFullName,
    required String inmateId,
    required String visitDate,
    required String startTime,
    required String endTime,
    String? itemsBrought,
  }) async {
    await ApiClient.instance.post(
      '/visits/family-friends',
      body: {
        'visitorFullName': visitorFullName,
        'inmateId': inmateId,
        'visitDate': visitDate,
        'startTime': startTime,
        'endTime': endTime,
        if (itemsBrought != null && itemsBrought.trim().isNotEmpty)
          'itemsBrought': itemsBrought.trim(),
      },
    );
  }
}

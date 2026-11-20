import '../core/api/api_client.dart';

class PrisonInfo {
  final String id;
  final String name;
  final String location;
  final bool active;

  const PrisonInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.active,
  });

  factory PrisonInfo.fromJson(Map<String, dynamic> json) {
    return PrisonInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed Prison').toString(),
      location: (json['location'] ?? 'Location not provided').toString(),
      active: json['active'] == true,
    );
  }
}

class CommissionerApiService {
  Future<List<PrisonInfo>> getPrisons() async {
    final records = await ApiClient.instance.getAllPages('/prisons');
    return records.map(PrisonInfo.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getTransfers({
    String? status,
  }) {
    return ApiClient.instance.getAllPages(
      '/transfers',
      filters: {
        if (status != null) 'status': status,
      },
    );
  }

  Future<void> approveTransfer(String id, {String note = ''}) async {
    await ApiClient.instance.post(
      '/transfers/$id/approve',
      body: {'note': note},
    );
  }

  Future<void> rejectTransfer(String id, {String note = ''}) async {
    await ApiClient.instance.post(
      '/transfers/$id/reject',
      body: {'note': note},
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
  }) {
    return ApiClient.instance.getAllPages(
      '/notifications',
      filters: {
        if (unreadOnly) 'unreadOnly': 'true',
      },
    );
  }

  Future<void> markNotificationRead(String id) async {
    await ApiClient.instance.patch('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await ApiClient.instance.patch('/notifications/read-all');
  }

  Future<int> getUnreadNotificationCount() async {
    final response =
        await ApiClient.instance.get('/notifications/unread-count');

    if (response is num) return response.toInt();

    if (response is Map) {
      final count = response['count'] ??
          response['unreadCount'] ??
          response['unread_count'];
      if (count is num) return count.toInt();
      if (count != null) {
        final parsed = int.tryParse(count.toString());
        if (parsed != null) return parsed;
      }
    }

    throw const ApiException('Unexpected notification count response.');
  }
}

import '../core/api/api_client.dart';

class RecordsOfficerDashboardStats {
  final int totalInmates;
  final int newRegistrations;
  final int totalVisits;
  final int recordsUpdated;

  const RecordsOfficerDashboardStats({
    required this.totalInmates,
    required this.newRegistrations,
    required this.totalVisits,
    required this.recordsUpdated,
  });
}

class RecordsOfficerApiService {
  static Future<RecordsOfficerDashboardStats> getDashboardStats() async {
    final api = ApiClient.instance;
    final inmates = await api.getAllPages('/inmates');
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    int countSince(String field) {
      return inmates.where((inmate) {
        final value = inmate[field]?.toString();
        final date = value == null ? null : DateTime.tryParse(value);
        return date != null && !date.isBefore(startOfMonth);
      }).length;
    }

    return RecordsOfficerDashboardStats(
      totalInmates: inmates.length,
      newRegistrations: countSince('createdAt'),
      totalVisits: await api.getTotalElements('/visits'),
      recordsUpdated: countSince('updatedAt'),
    );
  }
}

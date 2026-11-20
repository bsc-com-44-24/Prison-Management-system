import '../core/api/api_client.dart';

class PrisonOfficerDashboardStats {
  final int totalInmates;
  final int totalTransfers;
  final int? upcomingReleases;
  final int? totalReleases;

  const PrisonOfficerDashboardStats({
    required this.totalInmates,
    required this.totalTransfers,
    this.upcomingReleases,
    this.totalReleases,
  });
}

class PrisonOfficerApiService {
  static Future<PrisonOfficerDashboardStats> getDashboardStats() async {
    final api = ApiClient.instance;
    final results = await Future.wait([
      api.getTotalElements('/inmates'),
      api.getTotalElements('/transfers'),
    ]);

    return PrisonOfficerDashboardStats(
      totalInmates: results[0],
      totalTransfers: results[1],
    );
  }
}

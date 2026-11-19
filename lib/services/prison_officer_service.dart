
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrisonOfficerDashboardStats {
  final int totalInmates;
  final int totalTransfers;
  final int upcomingReleases;
  final int totalReleases;

  const PrisonOfficerDashboardStats({
    required this.totalInmates,
    required this.totalTransfers,
    required this.upcomingReleases,
    required this.totalReleases,
  });

  factory PrisonOfficerDashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrisonOfficerDashboardStats(
      totalInmates: _toInt(json['totalInmates']),
      totalTransfers: _toInt(json['totalTransfers']),
      upcomingReleases: _toInt(json['upcomingReleases']),
      totalReleases: _toInt(json['totalReleases']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PrisonOfficerApiService {
  // Change this address to your backend's address when necessary.
  static const String baseUrl = 'http://localhost:8080';

  static Future<PrisonOfficerDashboardStats> getDashboardStats({
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/prison-officer/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Supports either a direct response or a response wrapped in "data".
      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> && decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'])
              : Map<String, dynamic>.from(decoded);

      return PrisonOfficerDashboardStats.fromJson(data);
    }

    throw Exception(
      'Unable to load dashboard statistics. '
      'Server returned ${response.statusCode}.',
    );
  }
}

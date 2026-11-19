
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  factory RecordsOfficerDashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecordsOfficerDashboardStats(
      totalInmates: _toInt(json['totalInmates']),
      newRegistrations: _toInt(json['newRegistrations']),
      totalVisits: _toInt(json['totalVisits']),
      recordsUpdated: _toInt(json['recordsUpdated']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class RecordsOfficerApiService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<RecordsOfficerDashboardStats> getDashboardStats({
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/records-officer/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> &&
                  decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'])
              : Map<String, dynamic>.from(decoded);

      return RecordsOfficerDashboardStats.fromJson(data);
    }

    throw Exception(
      'Unable to load dashboard statistics. '
      'Server returned ${response.statusCode}.',
    );
  }
}


import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgramFacilitatorDashboardStats {
  final int totalProgrammes;
  final int participatingInmates;
  final int activeProgrammes;
  final int completedProgrammes;

  ProgramFacilitatorDashboardStats({
    required this.totalProgrammes,
    required this.participatingInmates,
    required this.activeProgrammes,
    required this.completedProgrammes,
  });

  factory ProgramFacilitatorDashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    int getInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ProgramFacilitatorDashboardStats(
      totalProgrammes: getInt(json['totalProgrammes']),
      participatingInmates: getInt(json['participatingInmates']),
      activeProgrammes: getInt(json['activeProgrammes']),
      completedProgrammes: getInt(json['completedProgrammes']),
    );
  }
}

class ProgramFacilitatorApiService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<ProgramFacilitatorDashboardStats> getDashboardStats({
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/program-facilitator/dashboard'),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> && decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'])
              : Map<String, dynamic>.from(decoded as Map);

      return ProgramFacilitatorDashboardStats.fromJson(data);
    }

    throw Exception(
      'Failed to load dashboard statistics. '
      'Status code: ${response.statusCode}',
    );
  }
}

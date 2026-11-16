import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardStats {
  final int totalUsers;
  final int registeredPrisons;

  const DashboardStats({
    required this.totalUsers,
    required this.registeredPrisons,
  });
}

class DashboardApiService {
  // Replace this with your actual Spring Boot backend URL.
  static const String baseUrl = 'http://localhost:8080';

  // Backend team will implement these endpoints.
  static const String usersCountEndpoint = '/api/users/count';
  static const String prisonsCountEndpoint = '/api/prisons/count';

  static Future<int> getTotalUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl$usersCountEndpoint'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is int) return data;
      if (data is Map && data['count'] != null) {
        return int.parse(data['count'].toString());
      }

      throw Exception('Unexpected users count response');
    }

    throw Exception('Failed to load total users');
  }

  static Future<int> getRegisteredPrisons() async {
    final response = await http.get(
      Uri.parse('$baseUrl$prisonsCountEndpoint'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is int) return data;
      if (data is Map && data['count'] != null) {
        return int.parse(data['count'].toString());
      }

      throw Exception('Unexpected prisons count response');
    }

    throw Exception('Failed to load registered prisons');
  }

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

import 'dart:convert';
import 'package:http/http.dart' as http;

class PrisonInfo {
  final String id;
  final String name;
  final int capacity;
  final int currentInmates;

  const PrisonInfo({
    required this.id,
    required this.name,
    required this.capacity,
    required this.currentInmates,
  });

  factory PrisonInfo.fromJson(Map<String, dynamic> json) {
    return PrisonInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['prisonName'] ?? 'Unnamed Prison')
          .toString(),
      capacity: _toInt(json['capacity']),
      currentInmates: _toInt(
        json['currentInmates'] ?? json['current_inmates'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double get occupancyPercentage {
    if (capacity <= 0) return 0;
    return (currentInmates / capacity) * 100;
  }
}

class CommissionerApiService {
  // Change this to your actual Spring Boot backend address.
  static const String baseUrl = 'http://localhost:8080';

  // Proposed endpoints for the backend team.
  static const String prisonsEndpoint = '/api/prisons';
  static const String notificationsEndpoint =
      '/api/notifications/unread-count';

  final String? token;

  CommissionerApiService({this.token});

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // Retrieve all prisons.
  Future<List<PrisonInfo>> getPrisons() async {
    final response = await http.get(
      Uri.parse('$baseUrl$prisonsEndpoint'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to retrieve prisons');
    }

    final decoded = jsonDecode(response.body);

    dynamic records = decoded;

    // Supports common Spring Boot response wrappers.
    if (decoded is Map) {
      records = decoded['data'] ??
          decoded['content'] ??
          decoded['prisons'] ??
          [];
    }

    if (records is! List) {
      throw Exception('Unexpected prisons response format');
    }

    return records
        .whereType<Map>()
        .map(
          (item) => PrisonInfo.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // Retrieve unread notification count.
  Future<int> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl$notificationsEndpoint'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to retrieve notifications');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is num) return decoded.toInt();

    if (decoded is Map) {
      final count = decoded['count'] ??
          decoded['unreadCount'] ??
          decoded['unread_count'];

      if (count != null) {
        return int.tryParse(count.toString()) ?? 0;
      }
    }

    throw Exception('Unexpected notification response format');
  }
}

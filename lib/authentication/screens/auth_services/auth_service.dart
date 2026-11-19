
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Change this URL if your backend uses a different address.
  static const String baseUrl = 'http://localhost:8080';

Future<void> resetPassword({
  required String email,
  required String idNumber,
  required String newPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'idNumber': idNumber.trim(),
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 404) {
      throw Exception(
        'Unable to verify your details. Check your email and ID number.',
      );
    }

    throw Exception(
      'Password reset failed. Server status: ${response.statusCode}',
    );
  } catch (e) {
    if (e is Exception) rethrow;

    throw Exception(
      'Unable to connect to the server. Please try again.',
    );
  }
}


  // Update this endpoint if your Spring Boot endpoint differs.
  static const String loginEndpoint = '/api/auth/login';

  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': emailOrUsername.trim(),
          'password': password,
        }),
      );

      final dynamic decodedResponse =
          response.body.isNotEmpty
              ? jsonDecode(response.body)
              : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedResponse is! Map) {
          throw Exception('Invalid response received from server.');
        }

        final Map<String, dynamic> responseData =
            Map<String, dynamic>.from(decodedResponse);

        // Support APIs that wrap their response inside "data".
        final Map<String, dynamic> userData =
            responseData['data'] is Map
                ? Map<String, dynamic>.from(responseData['data'])
                : responseData;

        final String? token =
            userData['accessToken']?.toString() ??
            userData['access_token']?.toString() ??
            userData['token']?.toString();

        if (token == null || token.isEmpty) {
          throw Exception('Authentication token was not returned.');
        }

        final dynamic roleValue =
            userData['role'] ??
            userData['userRole'] ??
            userData['user_role'];

        if (roleValue == null) {
          throw Exception('User role was not returned by the server.');
        }

        return {
          ...userData,
          'access_token': token,
          'role': roleValue.toString(),
        };
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Invalid email/username or password.');
      }

      if (response.statusCode == 400) {
        throw Exception('Please check your login details.');
      }

      throw Exception(
        'Login failed. Server returned status ${response.statusCode}.',
      );
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (e) {
      if (e is Exception) rethrow;

      throw Exception(
        'Unable to connect to the server. Please try again.',
      );
    }
  }
}

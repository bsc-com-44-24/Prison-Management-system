import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static final _storage = FlutterSecureStorage();

  final http.Client _http = http.Client();

  String? _accessToken;

  bool get hasSession => _accessToken != null && _accessToken!.isNotEmpty;

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }

    // Android emulator host loopback. For a physical device, pass the host
    // machine's LAN URL with --dart-define=API_BASE_URL=http://<host>:8080/api/v1.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }

    // Web and other platforms
    return 'http://localhost:8080/api/v1';
  }

  Future<void> restoreSession() async {
    _accessToken = await _storage.read(key: 'access_token');
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    _accessToken = token;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: 'access_token');
    _accessToken = null;
  }

  Future<Object?> get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) {
    return _request('GET', path, queryParameters: queryParameters);
  }

  Future<int> getTotalElements(String path) async {
    final response = await get(
      path,
      queryParameters: const {'page': '0', 'size': '1'},
    );

    if (response is Map && response['totalElements'] is num) {
      return (response['totalElements'] as num).toInt();
    }

    throw ApiException(
      'The paginated response from $path has no totalElements.',
    );
  }

  Future<List<Map<String, dynamic>>> getAllPages(
    String path, {
    Map<String, String> filters = const {},
    int pageSize = 100,
  }) async {
    final records = <Map<String, dynamic>>[];
    var page = 0;
    var totalPages = 1;

    while (page < totalPages) {
      final response = await get(
        path,
        queryParameters: {
          ...filters,
          'page': '$page',
          'size': '$pageSize',
        },
      );

      if (response is! Map || response['content'] is! List) {
        throw ApiException('Unexpected paginated response from $path.');
      }

      records.addAll(
        (response['content'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item)),
      );

      final reportedPages = response['totalPages'];
      totalPages = reportedPages is num ? reportedPages.toInt() : page + 1;

      page++;
    }

    return records;
  }

  Future<Object?> post(String path, {Object? body}) {
    return _request('POST', path, body: body);
  }

  Future<Object?> put(String path, {Object? body}) {
    return _request('PUT', path, body: body);
  }

  Future<Object?> patch(String path, {Object? body}) {
    return _request('PATCH', path, body: body);
  }

  Future<Object?> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    Uint8List? photo,
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json';

    final token = _accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      http.MultipartFile.fromString(
        'inmate',
        jsonEncode(fields),
        contentType: MediaType('application', 'json'),
      ),
    );
    if (photo != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photo,
          filename: 'inmate.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    late final http.Response response;
    try {
      final streamedResponse =
          await _http.send(request).timeout(const Duration(seconds: 20));
      response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException('The API request timed out.');
    } on http.ClientException catch (error) {
      throw ApiException(
        'Unable to connect to the API server: ${error.message}',
      );
    }

    return _decodeResponse(response);
  }

  Future<Object?> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String> queryParameters = const {},
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    final token = _accessToken;

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    late final http.Response response;

    try {
      final streamedResponse =
          await _http.send(request).timeout(const Duration(seconds: 20));

      response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException('The API request timed out.');
    } on http.ClientException catch (error) {
      throw ApiException(
        'Unable to connect to the API server: ${error.message}',
      );
    }

    return _decodeResponse(response);
  }

  Object? _decodeResponse(http.Response response) {
    final responseBody = response.body;
    Object? decoded;

    if (responseBody.isNotEmpty) {
      try {
        decoded = jsonDecode(responseBody);
      } on FormatException {
        decoded = responseBody;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'Request failed (${response.statusCode})';

      if (decoded is Map<String, dynamic>) {
        final detail =
            decoded['message'] ?? decoded['detail'] ?? decoded['error'];

        if (detail is String && detail.isNotEmpty) {
          message = detail;
        }
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}

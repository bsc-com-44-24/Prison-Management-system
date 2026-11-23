import 'dart:typed_data';

import '../core/api/api_client.dart';

class InmateApiService {
  static Future<List<Map<String, dynamic>>> getInmates({
    String? search,
    String? gender,
  }) {
    return ApiClient.instance.getAllPages(
      '/inmates',
      filters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (gender != null && gender.isNotEmpty) 'gender': gender,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getCells({
    String? prisonId,
    String? blockId,
  }) {
    return ApiClient.instance.getAllPages(
      '/cells',
      filters: {
        if (prisonId != null) 'prisonId': prisonId,
        if (blockId != null) 'blockId': blockId,
      },
    );
  }

  static Future<Map<String, dynamic>> createInmate({
    required Map<String, dynamic> inmate,
    Uint8List? photo,
  }) async {
    final response = await ApiClient.instance.postMultipart(
      '/inmates',
      fields: inmate,
      photo: photo,
    );
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException('Unexpected response when registering inmate.');
  }

  static Future<Map<String, dynamic>> updateInmate({
    required String id,
    required Map<String, dynamic> inmate,
  }) async {
    final response =
        await ApiClient.instance.patch('/inmates/$id', body: inmate);
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException('Unexpected response when updating inmate.');
  }

  static Future<void> allocateCell({
    required String inmateId,
    required String cellId,
  }) async {
    await ApiClient.instance.put(
      '/inmates/$inmateId/cell-allocation',
      body: {'cellId': cellId},
    );
  }

  static Future<void> createSentence({
    required String inmateId,
    required String offence,
    required String sentenceType,
    required String startDate,
    String? endDate,
  }) async {
    await ApiClient.instance.post(
      '/sentences',
      body: {
        'inmateId': inmateId,
        'offence': offence,
        'sentenceType': sentenceType,
        'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      },
    );
  }

  static Future<Object?> dischargeInmate(String id) {
    return ApiClient.instance.post('/inmates/$id/discharge');
  }

  static Future<List<Map<String, dynamic>>> getVisits(String inmateId) {
    return ApiClient.instance.getAllPages('/inmates/$inmateId/visits');
  }
}

import 'package:hive/hive.dart';

import '../Inmate_management/models/inmate_model.dart';

class DBHelper {
  static final Box _box = Hive.box('inmates_box');

  // Get all inmates
  static List<InmateModel> getInmates() {
    final rawData = _box.values.toList();
    return rawData
        .map((e) => InmateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Add or update inmate (using inmate.id as the key ensures updates overwrite correctly)
  static Future<void> addInmate(InmateModel inmate) async {
    await _box.put(inmate.id, inmate.toJson());
  }

  // Delete inmate
  static Future<void> deleteInmate(String id) async {
    await _box.delete(id);
  }
}

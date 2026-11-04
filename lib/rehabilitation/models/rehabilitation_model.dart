import 'package:hive/hive.dart';

@HiveType(typeId: 2) // Make sure typeId is unique across your models
class RehabilitationProgram extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // e.g., "Vocational Training"

  @HiveField(2)
  final String category; // e.g., "Carpentry, Tailoring, Metalwork"

  @HiveField(3)
  List<String> assignedInmateIds; // List of inmate IDs assigned to this program

  RehabilitationProgram({
    required this.id,
    required this.title,
    required this.category,
    required this.assignedInmateIds,
  });
}

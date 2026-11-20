import 'dart:typed_data';

class InmateModel {
  final String id;
  final String fullName;
  final String gender;
  final int age;
  final String dateOfBirth;
  final String nationality;
  final String facility;
  final String offenceCategory;
  final int sentenceYears;
  final String releaseDate;
  final String status; // 'Active', 'Under Review', or 'Released'
  final List<Uint8List> photos;

  InmateModel({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.dateOfBirth,
    required this.nationality,
    required this.facility,
    required this.offenceCategory,
    required this.sentenceYears,
    required this.releaseDate,
    required this.status,
    this.photos = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'gender': gender,
    'age': age,
    'dateOfBirth': dateOfBirth,
    'nationality': nationality,
    'facility': facility,
    'offenceCategory': offenceCategory,
    'sentenceYears': sentenceYears,
    'releaseDate': releaseDate,
    'status': status,
    'photos': photos,
  };

  factory InmateModel.fromJson(Map<dynamic, dynamic> json) => InmateModel(
    id: json['id'] ?? '',
    fullName: json['fullName'] ?? '',
    gender: json['gender'] ?? '',
    age: json['age'] ?? 0,
    dateOfBirth: json['dateOfBirth'] ?? '',
    nationality: json['nationality'] ?? '',
    facility: json['facility'] ?? '',
    offenceCategory: json['offenceCategory'] ?? '',
    sentenceYears: json['sentenceYears'] ?? 0,
    releaseDate: json['releaseDate'] ?? '',
    status: json['status'] ?? 'Active',
    photos: json['photos'] != null
        ? List<Uint8List>.from(json['photos'])
        : const [],
  );
}

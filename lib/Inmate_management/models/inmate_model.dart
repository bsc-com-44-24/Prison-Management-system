import 'dart:typed_data';

class InmateModel {
  final String id;
  final String fullName;
  final String gender;
  final int age;
  final String dateOfBirth;
  final String admissionDate;
  final String inmateType;
  final String nationality;
  final String facility;
  final String cellId;
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
    this.admissionDate = '',
    this.inmateType = 'REMAND',
    required this.nationality,
    required this.facility,
    this.cellId = '',
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
        'admissionDate': admissionDate,
        'inmateType': inmateType,
        'nationality': nationality,
        'facility': facility,
        'cellId': cellId,
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
        admissionDate: json['admissionDate'] ?? '',
        inmateType: json['inmateType'] ?? 'REMAND',
        nationality: json['nationality'] ?? '',
        facility: json['facility'] ?? '',
        cellId: json['cellId'] ?? '',
        offenceCategory: json['offenceCategory'] ?? '',
        sentenceYears: json['sentenceYears'] ?? 0,
        releaseDate: json['releaseDate'] ?? '',
        status: json['status'] ?? 'Active',
        photos: json['photos'] != null
            ? List<Uint8List>.from(json['photos'])
            : const [],
      );

  factory InmateModel.fromApiJson(Map<String, dynamic> json) {
    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final dateOfBirth = json['dateOfBirth']?.toString() ?? '';
    final birthDate = DateTime.tryParse(dateOfBirth);
    final now = DateTime.now();
    var age = 0;
    if (birthDate != null) {
      age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
    }

    return InmateModel(
      id: json['id']?.toString() ?? '',
      fullName: '$firstName $lastName'.trim(),
      gender: json['gender']?.toString() ?? '',
      age: age,
      dateOfBirth: dateOfBirth,
      admissionDate: json['admissionDate']?.toString() ?? '',
      inmateType: json['inmateType']?.toString() ?? 'REMAND',
      nationality: '',
      facility: json['prisonName']?.toString() ?? '',
      cellId: json['cellId']?.toString() ?? '',
      offenceCategory: '',
      sentenceYears: 0,
      releaseDate: '',
      status: json['status']?.toString() ?? 'Active',
    );
  }
}

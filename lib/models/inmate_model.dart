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
  final String status; // 'Active' or 'Under Review'

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
  });
}

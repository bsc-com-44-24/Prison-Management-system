class Visitor {
  final int? id;
  final String? apiId;
  final String name;
  final String idNumber;
  final String phone;
  final String relationship;
  final String inmateName;
  final String purpose;
  final String belongings;
  final String status;
  final DateTime visitDateTime;

  const Visitor({
    this.id,
    this.apiId,
    required this.name,
    required this.idNumber,
    required this.phone,
    required this.relationship,
    required this.inmateName,
    required this.purpose,
    required this.belongings,
    required this.status,
    required this.visitDateTime,
  });

  factory Visitor.fromApiJson(Map<String, dynamic> json) {
    final visitor = json['visitor'] is Map
        ? Map<String, dynamic>.from(json['visitor'] as Map)
        : const <String, dynamic>{};
    final inmate = json['inmate'] is Map
        ? Map<String, dynamic>.from(json['inmate'] as Map)
        : const <String, dynamic>{};
    final inmateName = json['inmateName']?.toString() ??
        inmate['fullName']?.toString() ??
        [inmate['firstName'], inmate['lastName']]
            .where((part) => part != null && part.toString().isNotEmpty)
            .join(' ');
    final rawDate = json['startDateTime']?.toString() ??
        json['visitDate']?.toString() ??
        DateTime.now().toIso8601String();
    return Visitor(
      apiId: json['id']?.toString(),
      name: json['visitorName']?.toString() ??
          visitor['fullName']?.toString() ??
          'Visitor',
      idNumber: '',
      phone: '',
      relationship: json['visitType']?.toString() ?? '',
      inmateName: inmateName,
      purpose: json['visitType']?.toString() ?? '',
      belongings: json['itemsBrought']?.toString() ?? '',
      status: 'Recorded',
      visitDateTime: DateTime.tryParse(rawDate) ?? DateTime.now(),
    );
  }

  // Convert a visitor into a format SQLite can store.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'idNumber': idNumber,
      'phone': phone,
      'relationship': relationship,
      'inmateName': inmateName,
      'purpose': purpose,
      'belongings': belongings,
      'status': status,
      'visitDateTime': visitDateTime.toIso8601String(),
    };
  }

  // Convert a database record back into a Visitor object.
  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'] as int?,
      name: map['name'] as String,
      idNumber: map['idNumber'] as String,
      phone: map['phone'] as String,
      relationship: map['relationship'] as String,
      inmateName: map['inmateName'] as String,
      purpose: map['purpose'] as String,
      belongings: map['belongings'] as String,
      status: map['status'] as String,
      visitDateTime: DateTime.parse(map['visitDateTime'] as String),
    );
  }
}

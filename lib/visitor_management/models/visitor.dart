class Visitor {
  final int? id;
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

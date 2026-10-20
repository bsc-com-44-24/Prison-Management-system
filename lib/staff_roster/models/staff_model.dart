class ShiftModel {
  final String shiftName;
  final String timeRange;
  final String status;
  final String supervisorName;
  final String supervisorRole;
  final String assignedLocation;
  final int officerCount;

  ShiftModel({
    required this.shiftName,
    required this.timeRange,
    required this.status,
    required this.supervisorName,
    required this.supervisorRole,
    required this.assignedLocation,
    required this.officerCount,
  });

  // Convert ShiftModel to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'shiftName': shiftName,
      'timeRange': timeRange,
      'status': status,
      'supervisorName': supervisorName,
      'supervisorRole': supervisorRole,
      'assignedLocation': assignedLocation,
      'officerCount': officerCount,
    };
  }

  // Create ShiftModel from local storage Map
  factory ShiftModel.fromMap(Map<dynamic, dynamic> map) {
    return ShiftModel(
      shiftName: map['shiftName'] ?? '',
      timeRange: map['timeRange'] ?? '',
      status: map['status'] ?? '',
      supervisorName: map['supervisorName'] ?? '',
      supervisorRole: map['supervisorRole'] ?? '',
      assignedLocation: map['assignedLocation'] ?? '',
      officerCount: map['officerCount'] ?? 0,
    );
  }
}
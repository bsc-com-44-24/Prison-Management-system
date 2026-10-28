class ShiftModel {
  final String shiftName;
  final String timeRange;
  final String status;
  final String supervisorName;
  final String supervisorRole;
  final String assignedLocation;
  final int officerCount;
  final String supervisorPhone; // Added for contact view
  final String supervisorEmail; // Added for contact view
  final List<String> assignedGuards; // Added for shift logs

  ShiftModel({
    required this.shiftName,
    required this.timeRange,
    required this.status,
    required this.supervisorName,
    required this.supervisorRole,
    required this.assignedLocation,
    required this.officerCount,
    this.supervisorPhone = '+265 99 123 4567',
    this.supervisorEmail = 'supervisor@prisons.gov.mw',
    this.assignedGuards = const ['Officer J. Banda', 'Officer T. Phiri', 'Officer L. Nkhata'],
  });

  Map<String, dynamic> toMap() {
    return {
      'shiftName': shiftName,
      'timeRange': timeRange,
      'status': status,
      'supervisorName': supervisorName,
      'supervisorRole': supervisorRole,
      'assignedLocation': assignedLocation,
      'officerCount': officerCount,
      'supervisorPhone': supervisorPhone,
      'supervisorEmail': supervisorEmail,
      'assignedGuards': assignedGuards,
    };
  }

  factory ShiftModel.fromMap(Map<dynamic, dynamic> map) {
    return ShiftModel(
      shiftName: map['shiftName']?.toString() ?? '',
      timeRange: map['timeRange']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Scheduled',
      supervisorName: map['supervisorName']?.toString() ?? 'Supervisor',
      supervisorRole: map['supervisorRole']?.toString() ?? 'Guard Lead',
      assignedLocation: map['assignedLocation']?.toString() ?? 'Main Block',
      officerCount: map['officerCount'] is int ? map['officerCount'] : int.tryParse(map['officerCount']?.toString() ?? '0') ?? 0,
      supervisorPhone: map['supervisorPhone']?.toString() ?? '+265 99 123 4567',
      supervisorEmail: map['supervisorEmail']?.toString() ?? 'supervisor@prisons.gov.mw',
      assignedGuards: map['assignedGuards'] != null 
          ? List<String>.from(map['assignedGuards']) 
          : ['Officer J. Banda', 'Officer T. Phiri', 'Officer L. Nkhata'],
    );
  }
}
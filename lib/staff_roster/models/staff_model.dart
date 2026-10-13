class ShiftModel {
  final String shiftName; // e.g., Morning Shift, Afternoon Shift, Night Shift
  final String timeRange; // e.g., 06:00 - 14:00
  final String status; // e.g., Active Now, Scheduled, High Alert
  final String supervisorName; // e.g., Officer M. Banda
  final String supervisorRole; // e.g., Supervisor, Guard Lead
  final String assignedLocation; // e.g., Maula Yard & Perimeter
  final int officerCount; // e.g., 6 Officers

  ShiftModel({
    required this.shiftName,
    required this.timeRange,
    required this.status,
    required this.supervisorName,
    required this.supervisorRole,
    required this.assignedLocation,
    required this.officerCount,
  });
}
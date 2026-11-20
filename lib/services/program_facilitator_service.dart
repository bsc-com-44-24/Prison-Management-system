import '../core/api/api_client.dart';

class ProgramFacilitatorDashboardStats {
  final int totalProgrammes;
  final int participatingInmates;
  final int activeProgrammes;
  final int completedProgrammes;

  const ProgramFacilitatorDashboardStats({
    required this.totalProgrammes,
    required this.participatingInmates,
    required this.activeProgrammes,
    required this.completedProgrammes,
  });
}

class ProgramFacilitatorDashboardData {
  final ProgramFacilitatorDashboardStats stats;
  final List<Map<String, dynamic>> programmes;

  const ProgramFacilitatorDashboardData({
    required this.stats,
    required this.programmes,
  });
}

class ProgramFacilitatorApiService {
  static Future<ProgramFacilitatorDashboardData> getDashboardData() async {
    final api = ApiClient.instance;
    final results = await Future.wait([
      api.getAllPages('/programs'),
      api.getAllPages('/programs/enrollments'),
    ]);
    final programmes = results[0];
    final enrollments = results[1];
    final participatingInmates = enrollments
        .map((enrollment) => enrollment['inmateId']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;

    return ProgramFacilitatorDashboardData(
      programmes: programmes,
      stats: ProgramFacilitatorDashboardStats(
        totalProgrammes: programmes.length,
        participatingInmates: participatingInmates,
        activeProgrammes: programmes
            .where((program) =>
                program['status']?.toString().toUpperCase() == 'ACTIVE')
            .length,
        completedProgrammes: programmes
            .where((program) =>
                program['status']?.toString().toUpperCase() == 'COMPLETED')
            .length,
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> getPrograms() {
    return ApiClient.instance.getAllPages('/programs');
  }

  static Future<List<Map<String, dynamic>>> getEnrollments({
    String? programId,
    String? inmateId,
  }) {
    return ApiClient.instance.getAllPages(
      '/programs/enrollments',
      filters: {
        if (programId != null) 'programId': programId,
        if (inmateId != null) 'inmateId': inmateId,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getAttendance({
    String? programName,
    String? inmateId,
  }) {
    return ApiClient.instance.getAllPages(
      '/programs/attendance',
      filters: {
        if (programName != null) 'programName': programName,
        if (inmateId != null) 'inmateId': inmateId,
      },
    );
  }

  static Future<void> createProgram({
    required String name,
    String? description,
    String? schedule,
    String? instructorUserId,
  }) async {
    await ApiClient.instance.post(
      '/programs',
      body: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (schedule != null && schedule.isNotEmpty) 'schedule': schedule,
        if (instructorUserId != null && instructorUserId.isNotEmpty)
          'instructorUserId': instructorUserId,
      },
    );
  }

  static Future<void> createEnrollment({
    required String inmateId,
    required String programId,
    required String enrollmentDate,
  }) async {
    await ApiClient.instance.post(
      '/programs/enrollments',
      body: {
        'inmateId': inmateId,
        'programId': programId,
        'enrollmentDate': enrollmentDate,
      },
    );
  }

  static Future<void> recordAttendance({
    required String inmateId,
    required String programId,
    required String sessionDate,
    required String attendanceStatus,
    String? remarks,
  }) async {
    await ApiClient.instance.post(
      '/programs/attendance',
      body: {
        'inmateId': inmateId,
        'programId': programId,
        'sessionDate': sessionDate,
        'attendanceStatus': attendanceStatus,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
    );
  }
}

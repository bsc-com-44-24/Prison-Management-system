
import 'package:material_ui/material_ui.dart';
import '../../../services/program_facilitator_service.dart';

class ProgramFacilitatorDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  final VoidCallback? onCreateProgramme;
  final VoidCallback? onManageParticipation;
  final VoidCallback? onRecordAttendance;

  const ProgramFacilitatorDashboardScreen({
    super.key,
    required this.user,
    this.onCreateProgramme,
    this.onManageParticipation,
    this.onRecordAttendance,
  });

  @override
  State<ProgramFacilitatorDashboardScreen> createState() =>
      _ProgramFacilitatorDashboardScreenState();
}

class _ProgramFacilitatorDashboardScreenState
    extends State<ProgramFacilitatorDashboardScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color backgroundColor = Color(0xFFF4F5F3);

  ProgramFacilitatorDashboardStats? stats;
  bool isLoading = true;
  String? errorMessage;

  String get userName {
    return widget.user['full_name']?.toString() ??
        widget.user['fullName']?.toString() ??
        widget.user['name']?.toString() ??
        widget.user['username']?.toString() ??
        widget.user['email']?.toString() ??
        'Program Facilitator';
  }

  String get userRole {
    return widget.user['role']?.toString() ??
        widget.user['user_role']?.toString() ??
        widget.user['userRole']?.toString() ??
        'Program Facilitator';
  }

  String? get token {
    return widget.user['access_token']?.toString() ??
        widget.user['accessToken']?.toString() ??
        widget.user['token']?.toString();
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await ProgramFacilitatorApiService.getDashboardStats(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        stats = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load dashboard statistics.';
        isLoading = false;
      });
    }
  }

  void showActionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: deepGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: deepGreen, size: 22),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: deepGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickAction({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: maroon.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: maroon, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: deepGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Program Facilitator',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showActionMessage('Notifications will appear here.');
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: deepGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: deepGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userRole,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: deepGreen,
                ),
              ),

              const SizedBox(height: 14),

              // Dynamic statistics
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      color: deepGreen,
                    ),
                  ),
                )
              else if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: maroon,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(errorMessage!),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: loadDashboard,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    buildStatCard(
                      title: 'Total Programmes',
                      value: '${stats!.totalProgrammes}',
                      icon: Icons.menu_book_outlined,
                    ),
                    buildStatCard(
                      title: 'Participating Inmates',
                      value: '${stats!.participatingInmates}',
                      icon: Icons.groups_outlined,
                    ),
                    buildStatCard(
                      title: 'Active Programmes',
                      value: '${stats!.activeProgrammes}',
                      icon: Icons.play_circle_outline,
                    ),
                    buildStatCard(
                      title: 'Completed Programmes',
                      value: '${stats!.completedProgrammes}',
                      icon: Icons.task_alt,
                    ),
                  ],
                ),

              const SizedBox(height: 26),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: deepGreen,
                ),
              ),

              const SizedBox(height: 14),

              // Exactly three quick actions
              buildQuickAction(
                title: 'Create Programme',
                description: 'Create a new rehabilitation programme',
                icon: Icons.add_circle_outline,
                onTap: widget.onCreateProgramme ??
                    () => showActionMessage(
                      'Create Programme screen will open here.',
                    ),
              ),

              const SizedBox(height: 12),

              buildQuickAction(
                title: 'Manage Participation',
                description: 'Manage inmates enrolled in programmes',
                icon: Icons.groups_outlined,
                onTap: widget.onManageParticipation ??
                    () => showActionMessage(
                      'Manage Participation screen will open here.',
                    ),
              ),

              const SizedBox(height: 12),

              buildQuickAction(
                title: 'Record Attendance',
                description: 'Record attendance for programme sessions',
                icon: Icons.fact_check_outlined,
                onTap: widget.onRecordAttendance ??
                    () => showActionMessage(
                      'Record Attendance screen will open here.',
                    ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

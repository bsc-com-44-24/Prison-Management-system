import 'package:material_ui/material_ui.dart';

import '../../../rehabilitation/screens/rehabilitation_screen.dart';
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
  List<Map<String, dynamic>> programmes = [];

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
      final result = await ProgramFacilitatorApiService.getDashboardData();

      if (!mounted) return;

      setState(() {
        stats = result.stats;
        programmes = result.programmes;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load dashboard information.';
        isLoading = false;
      });
    }
  }

  void showActionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openRehabilitation({int initialTab = 0}) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RehabilitationScreen(
          user: widget.user,
          initialTab: initialTab,
        ),
      ),
    );
    if (mounted) await loadDashboard();
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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

  // Quick action design follows the System Administrator dashboard.
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
        height: 155,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: deepGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: deepGreen,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: deepGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgrammeOverview() {
    if (programmes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 35,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            const Text(
              'Programme records are not available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: deepGreen,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Available programmes will appear here when '
              'the programme records API is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: programmes.map((programme) {
        final name = programme['name']?.toString() ??
            programme['programmeName']?.toString() ??
            'Unnamed Programme';

        final status = programme['status']?.toString() ?? 'Not specified';

        final description = programme['description']?.toString() ?? '';

        final isActive = status.toLowerCase() == 'active';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: deepGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: deepGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: deepGreen,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.10)
                            : maroon.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green : maroon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
            tooltip: 'Profile and sign out',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
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
              else ...[
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
                const SizedBox(height: 24),
                const Text(
                  'Available Programmes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: deepGreen,
                  ),
                ),
                const SizedBox(height: 14),
                buildProgrammeOverview(),
              ],

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

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  buildQuickAction(
                    title: 'Create Programme',
                    description: 'Create a new rehabilitation programme',
                    icon: Icons.add_circle_outline,
                    onTap:
                        widget.onCreateProgramme ?? () => _openRehabilitation(),
                  ),
                  buildQuickAction(
                    title: 'Manage Participation',
                    description: 'Manage inmates enrolled in programmes',
                    icon: Icons.groups_outlined,
                    onTap: widget.onManageParticipation ??
                        () => _openRehabilitation(),
                  ),
                  buildQuickAction(
                    title: 'Record Attendance',
                    description: 'Record attendance for programme sessions',
                    icon: Icons.fact_check_outlined,
                    onTap: widget.onRecordAttendance ??
                        () => _openRehabilitation(initialTab: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

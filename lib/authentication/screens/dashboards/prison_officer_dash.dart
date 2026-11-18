
import 'package:material_ui/material_ui.dart';

import '../../../services/prison_officer_service.dart';

class PrisonOfficerDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  // These callbacks will connect the quick actions to their screens.
  final VoidCallback? onReleaseManagement;
  final VoidCallback? onIssueTransfer;
  final VoidCallback? onViewInmates;

  const PrisonOfficerDashboardScreen({
    super.key,
    required this.user,
    this.onReleaseManagement,
    this.onIssueTransfer,
    this.onViewInmates,
  });

  @override
  State<PrisonOfficerDashboardScreen> createState() =>
      _PrisonOfficerDashboardScreenState();
}

class _PrisonOfficerDashboardScreenState
    extends State<PrisonOfficerDashboardScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color backgroundColor = Color(0xFFF4F5F3);

  late Future<PrisonOfficerDashboardStats> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = _loadDashboard();
  }

  String _getUserValue(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = widget.user[key]?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }

  String get userName => _getUserValue(
        ['full_name', 'fullName', 'name', 'username', 'email'],
        'User',
      );

  String get userRole => _getUserValue(
        ['role', 'user_role', 'userRole'],
        'Prison Officer',
      );

  String? get accessToken {
    final token = _getUserValue(
      ['access_token', 'accessToken', 'token'],
      '',
    );

    return token.isEmpty ? null : token;
  }

  Future<PrisonOfficerDashboardStats> _loadDashboard() {
    return PrisonOfficerApiService.getDashboardStats(
      token: accessToken,
    );
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      dashboardFuture = _loadDashboard();
    });

    try {
      await dashboardFuture;
    } catch (_) {
      // FutureBuilder displays the error and retry option.
    }
  }

  void _openAction(VoidCallback? callback, String actionName) {
    if (callback != null) {
      callback();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionName screen will be connected next.'),
        backgroundColor: deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: deepGreen,
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Prison Overview'),

                      const SizedBox(height: 14),

                      FutureBuilder<PrisonOfficerDashboardStats>(
                        future: dashboardFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 190,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: deepGreen,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return _buildErrorCard();
                          }

                          final stats = snapshot.data!;

                          return _buildStatistics(stats);
                        },
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle('Quick Actions'),

                      const SizedBox(height: 14),

                      _buildQuickActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 22),
      decoration: const BoxDecoration(
        color: deepGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu,
            color: Colors.white,
            size: 27,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prison Officer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 27,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $userName',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: deepGreen,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          userRole,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Manage your prison operations from one place.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: deepGreen,
      ),
    );
  }

  Widget _buildStatistics(PrisonOfficerDashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.42,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Inmates',
          value: stats.totalInmates,
          icon: Icons.groups_outlined,
          iconColor: deepGreen,
        ),

        _buildStatCard(
          title: 'Total Transfers',
          value: stats.totalTransfers,
          icon: Icons.swap_horiz,
          iconColor: maroon,
        ),

        _buildStatCard(
          title: 'Upcoming Releases',
          value: stats.upcomingReleases,
          icon: Icons.calendar_month_outlined,
          iconColor: deepGreen,
        ),

        _buildStatCard(
          title: 'Total Releases',
          value: stats.totalReleases,
          icon: Icons.door_front_door_outlined,
          iconColor: maroon,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 26,
          ),

          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: deepGreen,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard(
          title: 'Release Management',
          description: 'Manage inmate release procedures and requests',
          icon: Icons.assignment_outlined,
          iconColor: deepGreen,
          onTap: () => _openAction(
            widget.onReleaseManagement,
            'Release Management',
          ),
        ),

        const SizedBox(height: 12),

        _buildActionCard(
          title: 'Issue Transfer',
          description: 'Submit a request to transfer an inmate',
          icon: Icons.swap_horiz,
          iconColor: maroon,
          onTap: () => _openAction(
            widget.onIssueTransfer,
            'Issue Transfer',
          ),
        ),

        const SizedBox(height: 12),

        _buildActionCard(
          title: 'View Inmates',
          description: 'View, register and allocate inmates to cell blocks',
          icon: Icons.groups_outlined,
          iconColor: deepGreen,
          onTap: () => _openAction(
            widget.onViewInmates,
            'View Inmates',
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: deepGreen,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: maroon,
            size: 32,
          ),

          const SizedBox(height: 10),

          const Text(
            'Unable to load dashboard statistics',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: deepGreen,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
            style: TextButton.styleFrom(
              foregroundColor: deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}

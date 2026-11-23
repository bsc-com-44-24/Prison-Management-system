import 'package:material_ui/material_ui.dart';

import '../../../services/records_officer_service.dart';

class RecordsOfficerDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  final VoidCallback? onRegisterInmate;
  final VoidCallback? onManageInmates;
  final VoidCallback? onTrackInmates;
  final VoidCallback? onRegisterVisitor;

  const RecordsOfficerDashboardScreen({
    super.key,
    required this.user,
    this.onRegisterInmate,
    this.onManageInmates,
    this.onTrackInmates,
    this.onRegisterVisitor,
  });

  @override
  State<RecordsOfficerDashboardScreen> createState() =>
      _RecordsOfficerDashboardScreenState();
}

class _RecordsOfficerDashboardScreenState
    extends State<RecordsOfficerDashboardScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color backgroundColor = Color(0xFFF4F5F3);

  late Future<RecordsOfficerDashboardStats> dashboardFuture;

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
        'Records Officer',
      );

  Future<RecordsOfficerDashboardStats> _loadDashboard() {
    return RecordsOfficerApiService.getDashboardStats();
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

  void _openAction(
    VoidCallback? callback,
    String actionName,
  ) {
    if (callback != null) {
      callback();
      return;
    }

    final route = switch (actionName) {
      'Register Inmate' || 'Manage Inmates' => '/inmates',
      'Track Inmates' => '/tracking',
      'Register Visitor' => '/visitors',
      _ => null,
    };
    if (route != null) {
      Navigator.pushNamed(context, route);
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
                      _buildSectionTitle('Records Overview'),
                      const SizedBox(height: 14),
                      FutureBuilder<RecordsOfficerDashboardStats>(
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

  // HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
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
                Text(
                  userRole,
                  style: const TextStyle(
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
          IconButton(
            tooltip: 'Profile and sign out',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // WELCOME SECTION
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
        const SizedBox(height: 7),
        const Text(
          'Manage inmate and visitor records at your allocated prison.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // SECTION TITLE
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

  // STATISTICS GRID
  Widget _buildStatistics(RecordsOfficerDashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
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
          title: 'New Registrations',
          value: stats.newRegistrations,
          icon: Icons.person_add_alt_1,
          iconColor: maroon,
        ),
        _buildStatCard(
          title: 'Total Visits',
          value: stats.totalVisits,
          icon: Icons.people_outline,
          iconColor: deepGreen,
        ),
        _buildStatCard(
          title: 'Records Updated',
          value: stats.recordsUpdated,
          icon: Icons.fact_check_outlined,
          iconColor: maroon,
        ),
      ],
    );
  }

  // INDIVIDUAL STATISTIC CARD
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
            size: 27,
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

  // QUICK ACTIONS
  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard(
          title: 'Register Inmate',
          description: 'Add a new inmate and capture their details',
          icon: Icons.person_add_alt_1,
          iconColor: deepGreen,
          onTap: () => _openAction(
            widget.onRegisterInmate,
            'Register Inmate',
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Manage Inmates',
          description: 'View and update inmate records',
          icon: Icons.folder_shared_outlined,
          iconColor: maroon,
          onTap: () => _openAction(
            widget.onManageInmates,
            'Manage Inmates',
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Track Inmates',
          description: 'Monitor inmate status and cell-block allocation',
          icon: Icons.location_on_outlined,
          iconColor: deepGreen,
          onTap: () => _openAction(
            widget.onTrackInmates,
            'Track Inmates',
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Register Visitor',
          description: 'Record visitors and associate them with inmates',
          icon: Icons.person_add_alt,
          iconColor: maroon,
          onTap: () => _openAction(
            widget.onRegisterVisitor,
            'Register Visitor',
          ),
        ),
      ],
    );
  }

  // INDIVIDUAL QUICK ACTION CARD
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

  // ERROR CARD
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
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load records statistics',
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

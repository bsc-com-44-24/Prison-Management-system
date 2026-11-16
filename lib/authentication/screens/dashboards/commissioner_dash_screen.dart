import 'package:material_ui/material_ui.dart';

import '../../../authentication/screens/login_screen.dart';
import '../../../services/commissioner_service.dart';

class CommissionerDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  const CommissionerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<CommissionerDashboardScreen> createState() =>
      _CommissionerDashboardScreenState();
}

class _CommissionerDashboardScreenState
    extends State<CommissionerDashboardScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color background = Color(0xFFF4F5F3);

  List<PrisonInfo> prisons = [];

  int? notificationCount;

  bool isLoadingPrisons = true;
  bool isLoadingNotifications = true;

  String? prisonError;
  String? notificationError;

  late final CommissionerApiService apiService;

  String get commissionerName {
    return (widget.user['full_name'] ??
            widget.user['fullName'] ??
            widget.user['name'] ??
            widget.user['username'] ??
            widget.user['email'] ??
            'Commissioner')
        .toString();
  }

  @override
  void initState() {
    super.initState();

    final token =
        (widget.user['access_token'] ?? widget.user['token'])?.toString();

    apiService = CommissionerApiService(token: token);

    loadDashboardData();
  }

  int get totalPrisons => prisons.length;

  int get totalCapacity {
    return prisons.fold(
      0,
      (sum, prison) => sum + prison.capacity,
    );
  }

  int get totalInmates {
    return prisons.fold(
      0,
      (sum, prison) => sum + prison.currentInmates,
    );
  }

  double get averageCapacity {
    if (totalCapacity == 0) return 0;

    return (totalInmates / totalCapacity) * 100;
  }

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadPrisons(),
      loadNotifications(),
    ]);
  }

  Future<void> loadPrisons() async {
    setState(() {
      isLoadingPrisons = true;
      prisonError = null;
    });

    try {
      final result = await apiService.getPrisons();

      if (!mounted) return;

      setState(() {
        prisons = result;
        isLoadingPrisons = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingPrisons = false;
        prisonError = 'Unable to load prison information';
      });
    }
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoadingNotifications = true;
      notificationError = null;
    });

    try {
      final result = await apiService.getUnreadNotificationCount();

      if (!mounted) return;

      setState(() {
        notificationCount = result;
        isLoadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        notificationCount = null;
        isLoadingNotifications = false;
        notificationError = 'Unable to load notifications';
      });
    }
  }

  void showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title screen will be connected soon.'),
        backgroundColor: deepGreen,
      ),
    );
  }

  void openNotifications() {
    showComingSoon('Notifications');
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget buildHeader() {
    return Container(
      color: deepGreen,
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (sheetContext) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.dashboard),
                          title: const Text('Dashboard'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            loadDashboardData();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sign Out'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            logout();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commissioner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  commissionerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: openNotifications,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              if (notificationCount != null && notificationCount! > 0)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: maroon,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    child: Text(
                      notificationCount! > 99 ? '99+' : '$notificationCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EAE3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $commissionerName',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Prison Oversight Dashboard',
            style: TextStyle(
              fontSize: 14,
              color: deepGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrisonOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
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
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: deepGreen,
                size: 26,
              ),
              SizedBox(width: 12),
              Text(
                'Registered Prisons',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          if (isLoadingPrisons)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  color: deepGreen,
                ),
              ),
            )
          else if (prisonError != null)
            Center(
              child: Column(
                children: [
                  Text(
                    prisonError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: loadPrisons,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _overviewValue(
                        totalPrisons.toString(),
                        'Total Prisons',
                      ),
                    ),
                    Container(
                      height: 65,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _overviewValue(
                        totalCapacity == 0
                            ? '—'
                            : '${averageCapacity.toStringAsFixed(1)}%',
                        'National Occupancy',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (averageCapacity / 100).clamp(0.0, 1.0),
                    minHeight: 9,
                    backgroundColor: Colors.grey.shade200,
                    color: averageCapacity >= 90 ? maroon : deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalInmates inmates / $totalCapacity total capacity',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _overviewValue(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: deepGreen,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget buildPrisonList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prison Capacity Overview',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (prisons.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No prison records available.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ...prisons.map((prison) {
          final percentage = prison.occupancyPercentage;
          final progress = (percentage / 100).clamp(0.0, 1.0);

          final Color capacityColor = percentage >= 90 ? maroon : deepGreen;

          return Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: deepGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prison.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: capacityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: capacityColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${prison.currentInmates} inmates '
                  'of ${prison.capacity} capacity',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: deepGreen,
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: deepGreen,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: [
            buildQuickAction(
              icon: Icons.swap_horiz,
              title: 'View Transfer Requests',
              onTap: () => showComingSoon('Transfer Requests'),
            ),
            buildQuickAction(
              icon: Icons.description_outlined,
              title: 'View Release Requests',
              onTap: () => showComingSoon('Release Requests'),
            ),
            buildQuickAction(
              icon: Icons.history,
              title: 'Transfer History',
              onTap: () => showComingSoon('Transfer History'),
            ),
            buildQuickAction(
              icon: Icons.history_toggle_off,
              title: 'Release History',
              onTap: () => showComingSoon('Release History'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: deepGreen,
          onRefresh: loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildWelcomeCard(),
                      const SizedBox(height: 20),
                      buildPrisonOverview(),
                      const SizedBox(height: 25),
                      buildQuickActions(),
                      const SizedBox(height: 25),
                      buildPrisonList(),
                      const SizedBox(height: 20),
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
}

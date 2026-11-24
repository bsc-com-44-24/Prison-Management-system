import 'package:material_ui/material_ui.dart';

import '../../../authentication/screens/login_screen.dart';
import '../../../authentication/screens/auth_services/auth_service.dart';
import '../../../services/commissioner_service.dart';

class CommissionerDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  const CommissionerDashboardScreen({super.key, required this.user});

  @override
  State<CommissionerDashboardScreen> createState() =>
      _CommissionerDashboardScreenState();
}

class CommissionerNotificationsScreen extends StatefulWidget {
  const CommissionerNotificationsScreen({super.key});

  @override
  State<CommissionerNotificationsScreen> createState() =>
      _CommissionerNotificationsScreenState();
}

class _CommissionerNotificationsScreenState
    extends State<CommissionerNotificationsScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  final CommissionerApiService apiService = CommissionerApiService();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await apiService.getNotifications();
      if (!mounted) return;
      setState(() {
        notifications = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Unable to load notifications.';
        isLoading = false;
      });
    }
  }

  Future<void> markRead(Map<String, dynamic> notification) async {
    final id = notification['id']?.toString();
    if (id == null || id.isEmpty) return;
    await apiService.markNotificationRead(id);
    await loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F3),
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    await apiService.markAllNotificationsRead();
                    await loadNotifications();
                  },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : notifications.isEmpty
          ? const Center(child: Text('No notifications found'))
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final unread =
                      notification['read'] == false ||
                      notification['unread'] == true;
                  final title =
                      notification['title']?.toString() ?? 'Notification';
                  final message =
                      notification['message']?.toString() ??
                      notification['body']?.toString() ??
                      '';

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        unread
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: deepGreen,
                      ),
                      title: Text(title),
                      subtitle: message.isEmpty ? null : Text(message),
                      onTap: unread ? () => markRead(notification) : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class CommissionerTransfersScreen extends StatefulWidget {
  final bool pendingOnly;

  const CommissionerTransfersScreen({super.key, required this.pendingOnly});

  @override
  State<CommissionerTransfersScreen> createState() =>
      _CommissionerTransfersScreenState();
}

class _CommissionerTransfersScreenState
    extends State<CommissionerTransfersScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  final CommissionerApiService apiService = CommissionerApiService();
  List<Map<String, dynamic>> transfers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await apiService.getTransfers(
        status: widget.pendingOnly ? 'PENDING' : null,
      );
      if (!mounted) return;
      setState(() {
        transfers = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Unable to load transfers.';
        isLoading = false;
      });
    }
  }

  Future<void> updateTransfer(
    Map<String, dynamic> transfer,
    bool approve,
  ) async {
    final id = transfer['id']?.toString();
    if (id == null || id.isEmpty) return;
    if (approve) {
      await apiService.approveTransfer(id);
    } else {
      await apiService.rejectTransfer(id);
    }
    await loadTransfers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F3),
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text(
          widget.pendingOnly ? 'Transfer Requests' : 'Transfer History',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : transfers.isEmpty
          ? const Center(child: Text('No transfers found'))
          : RefreshIndicator(
              onRefresh: loadTransfers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: transfers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final transfer = transfers[index];
                  final status = transfer['status']?.toString() ?? 'PENDING';
                  final inmateName =
                      transfer['inmateName']?.toString() ??
                      transfer['inmateId']?.toString() ??
                      'Unknown inmate';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inmateName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text('Status: $status'),
                          if (widget.pendingOnly &&
                              status.toUpperCase() == 'PENDING') ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        updateTransfer(transfer, true),
                                    child: const Text('Approve'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        updateTransfer(transfer, false),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
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
    apiService = CommissionerApiService();

    loadDashboardData();
  }

  int get totalPrisons => prisons.length;

  Future<void> loadDashboardData() async {
    await Future.wait([loadPrisons(), loadNotifications()]);
  }

  Future<void> loadPrisons() async {
    if (mounted) {
      setState(() {
        isLoadingPrisons = true;
        prisonError = null;
      });
    }

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

  void showUnsupported(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title is not available in the current backend API.'),
        backgroundColor: deepGreen,
      ),
    );
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CommissionerNotificationsScreen(),
      ),
    ).then((_) => loadDashboardData());
  }

  void openTransferRequests({required bool pendingOnly}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CommissionerTransfersScreen(pendingOnly: pendingOnly),
      ),
    );
  }

  void openOverviewModule(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // --------------------------------------------------
  // REGISTERED PRISONS NAVIGATION
  // --------------------------------------------------

  void openRegisteredPrisons() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisteredPrisonsScreen(apiService: apiService),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

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
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Profile and sign out',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline, color: Colors.white),
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

  // --------------------------------------------------
  // WELCOME CARD
  // --------------------------------------------------

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
            style: TextStyle(fontSize: 14, color: deepGreen),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // REGISTERED PRISONS CARD
  // --------------------------------------------------

  Widget buildRegisteredPrisonsCard() {
    return InkWell(
      onTap: openRegisteredPrisons,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: deepGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                color: deepGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registered Prisons',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isLoadingPrisons)
                    const Text(
                      'Loading prison records...',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    )
                  else if (prisonError != null)
                    const Text(
                      'Unable to load prison records',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                  else
                    Text(
                      '$totalPrisons registered prisons',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            if (isLoadingPrisons)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: deepGreen,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: deepGreen, size: 27),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // QUICK ACTION CARD
  // --------------------------------------------------

  Widget buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
              child: Icon(icon, color: Colors.white, size: 24),
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
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // QUICK ACTIONS
  // --------------------------------------------------

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
              onTap: () => openTransferRequests(pendingOnly: true),
            ),
            buildQuickAction(
              icon: Icons.description_outlined,
              title: 'View Release Requests',
              onTap: () => openOverviewModule('/releases'),
            ),
            buildQuickAction(
              icon: Icons.history,
              title: 'Transfer History',
              onTap: () => openTransferRequests(pendingOnly: false),
            ),
            buildQuickAction(
              icon: Icons.history_toggle_off,
              title: 'Release History',
              onTap: () => openOverviewModule('/releases'),
            ),
            buildQuickAction(
              icon: Icons.groups_outlined,
              title: 'View Inmate Records',
              onTap: () => openOverviewModule('/inmates'),
            ),
            buildQuickAction(
              icon: Icons.location_on_outlined,
              title: 'Custody Tracking',
              onTap: () => openOverviewModule('/tracking'),
            ),
            buildQuickAction(
              icon: Icons.people_outline,
              title: 'Visit Records',
              onTap: () => openOverviewModule('/visitors'),
            ),
            buildQuickAction(
              icon: Icons.calendar_month_outlined,
              title: 'Duty Rosters',
              onTap: () => openOverviewModule('/staff'),
            ),
            buildQuickAction(
              icon: Icons.menu_book_outlined,
              title: 'Rehabilitation',
              onTap: () => openOverviewModule('/rehabilitation'),
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------
  // MAIN DASHBOARD
  // --------------------------------------------------

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
                      const SizedBox(height: 18),
                      buildRegisteredPrisonsCard(),
                      const SizedBox(height: 25),
                      buildQuickActions(),
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

// ==================================================
// REGISTERED PRISONS SCREEN
// ==================================================

class RegisteredPrisonsScreen extends StatefulWidget {
  final CommissionerApiService apiService;

  const RegisteredPrisonsScreen({super.key, required this.apiService});

  @override
  State<RegisteredPrisonsScreen> createState() =>
      _RegisteredPrisonsScreenState();
}

class _RegisteredPrisonsScreenState extends State<RegisteredPrisonsScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color background = Color(0xFFF4F5F3);

  List<PrisonInfo> prisons = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPrisons();
  }

  Future<void> loadPrisons() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await widget.apiService.getPrisons();

      if (!mounted) return;

      setState(() {
        prisons = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to retrieve registered prisons.';
      });
    }
  }

  Widget buildPrisonCard(PrisonInfo prison) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: deepGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: deepGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prison.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prison ID: ${prison.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  prison.location,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              Chip(
                label: Text(prison.active ? 'Active' : 'Inactive'),
                backgroundColor: prison.active
                    ? deepGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: prison.active ? deepGreen : Colors.black54,
                  fontSize: 11,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Registered Prisons',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: deepGreen,
        onRefresh: loadPrisons,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registered Prisons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: deepGreen,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'View prison location and operating status.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(35),
                    child: CircularProgressIndicator(color: deepGreen),
                  ),
                )
              else if (errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: maroon,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: loadPrisons,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (prisons.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: Colors.grey,
                          size: 45,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No registered prisons found.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Prisons',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${prisons.length} prisons',
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                ...prisons.map(buildPrisonCard),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

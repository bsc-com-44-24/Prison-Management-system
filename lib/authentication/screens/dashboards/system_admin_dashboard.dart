import 'package:material_ui/material_ui.dart';

import '../../../authentication/screens/login_screen.dart';
import '../../../services/admin_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032);
  static const Color pageBackground = Color(0xFFF4F5F3);

  int? _totalUsers;
  int? _registeredPrisons;

  bool _isLoadingStats = true;
  String? _statsError;

  String get _fullName => (widget.user['full_name'] ??
          widget.user['fullName'] ??
          'System Administrator')
      .toString();

  String get _email => (widget.user['email'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  // Fetch actual statistics from the Spring Boot backend.
  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final stats = await DashboardApiService.getDashboardStats();

      if (!mounted) return;

      setState(() {
        _totalUsers = stats.totalUsers;
        _registeredPrisons = stats.registeredPrisons;
        _isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStats = false;
        _statsError = 'Unable to load statistics';
      });
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen will be connected soon.'),
        backgroundColor: deepGreen,
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Create User':
        _showComingSoon('Create User');
        break;

      case 'Manage Users':
        _showComingSoon('Manage Users');
        break;

      case 'Roles & Permissions':
        _showComingSoon('Roles & Permissions');
        break;

      case 'Manage Prisons':
        _showComingSoon('Manage Prisons');
        break;
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: deepGreen,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _fullName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _email,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'System Administrator',
                style: TextStyle(
                  color: deepGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDrawerTap(String item) {
    Navigator.pop(context);

    switch (item) {
      case 'Dashboard':
        _loadDashboardStats();
        break;

      case 'Create User':
      case 'Manage Users':
      case 'Roles & Permissions':
      case 'Manage Prisons':
        _handleQuickAction(item);
        break;

      case 'Profile & Settings':
        _showProfile();
        break;

      case 'Sign Out':
        _logout();
        break;
    }
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: () => _handleDrawerTap(title),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int? value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                icon,
                color: deepGreen,
                size: 23,
              ),
            ],
          ),
          if (_isLoadingStats)
            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: deepGreen,
              ),
            )
          else
            Text(
              _statsError != null ? '—' : (value?.toString() ?? '—'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: deepGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _handleQuickAction(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: deepGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: deepGreen,
                size: 25,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: deepGreen,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              8,
              8,
              4,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Malawi Prisons Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showComingSoon('Notifications');
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: _showProfile,
                  icon: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_fullName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'System Administrator',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'National System Overview',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              25,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Users',
                    value: _totalUsers,
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Registered Prisons',
                    value: _registeredPrisons,
                    icon: Icons.account_balance_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        24,
        16,
        25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Manage the national prison system',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            childAspectRatio: 1.12,
            children: [
              _buildQuickAction(
                icon: Icons.person_add_alt_1,
                title: 'Create User',
                description: 'Create accounts and assign system roles.',
              ),
              _buildQuickAction(
                icon: Icons.manage_accounts_outlined,
                title: 'Manage Users',
                description: 'View and manage registered system users.',
              ),
              _buildQuickAction(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Roles & Permissions',
                description: 'Manage access levels and permissions.',
              ),
              _buildQuickAction(
                icon: Icons.account_balance_outlined,
                title: 'Manage Prisons',
                description: 'Register and manage prisons across Malawi.',
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
      key: _scaffoldKey,
      backgroundColor: pageBackground,
      drawer: Drawer(
        backgroundColor: deepGreen,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: deepGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/loggg.jpg',
                    height: 48,
                    width: 48,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 40,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Malawi Prisons Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fullName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              Icons.dashboard_outlined,
              'Dashboard',
            ),
            _buildDrawerItem(
              Icons.person_add_alt_1,
              'Create User',
            ),
            _buildDrawerItem(
              Icons.manage_accounts_outlined,
              'Manage Users',
            ),
            _buildDrawerItem(
              Icons.admin_panel_settings_outlined,
              'Roles & Permissions',
            ),
            _buildDrawerItem(
              Icons.account_balance_outlined,
              'Manage Prisons',
            ),
            _buildDrawerItem(
              Icons.person_outline,
              'Profile & Settings',
            ),
            const Divider(
              color: Colors.white24,
              height: 25,
            ),
            _buildDrawerItem(
              Icons.logout,
              'Sign Out',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: deepGreen,
          onRefresh: _loadDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildQuickActions(),
                if (_statsError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      20,
                    ),
                    child: Text(
                      'Statistics could not be loaded. '
                      'Pull down to try again.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
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

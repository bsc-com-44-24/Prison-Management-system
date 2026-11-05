import 'package:flutter/material.dart';

import '../theme.dart';
import 'login_screen.dart';
import '../../Inmate_management/screens/new_inmate_screen.dart';
import '../../visitor_management/screens/visitor_list_screen.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../../release_management/screens/release_management_screen.dart';

/// Main dashboard shown after a successful login.
///
/// Pass the authenticated user's details from LoginScreen:
/// DashboardScreen(user: authenticatedUser)
class DashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // These are placeholders until the dashboard is connected to your database.
  final int _totalInmates = 0;
  final int _onLeave = 0;
  final int _upcomingReleases = 0;
  final int _todaysVisitors = 0;

  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032);
  static const Color pageBackground = Color(0xFFF4F5F3);
  static const String fontFamily = 'Roboto';

  String get _fullName => (widget.user['full_name'] ?? 'User').toString();
  String get _email => (widget.user['email'] ?? '').toString();

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (!mounted) return;
    setState(() => _selectedIndex = 0);
  }

  void _openInmates() => _openScreen(const NewInmateScreen());

  void _openVisitors() => _openScreen(const VisitorListScreen());

  void _openTracking() => _openScreen(const TrackingScreen());

  void _openReleaseManagement() =>
      _openScreen(const ReleaseManagementScreen());

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: deepGreen,
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              _fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(_email),
            if (widget.user['officer_id'] != null ||
                widget.user['phone'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'ID: ${widget.user['officer_id'] ?? 'N/A'}'
                '  •  ${widget.user['phone'] ?? 'N/A'}',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonButton,
                  foregroundColor: Colors.white,
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
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Inmates':
        _openInmates();
        break;
      case 'Visitors':
        _openVisitors();
        break;
      case 'Tracking':
        _openTracking();
        break;
      case 'Release Management':
        _openReleaseManagement();
        break;
      case 'Rehabilitation':
      case 'Duty Roster':
      case 'Notifications':
        _showComingSoon(action);
        break;
      default:
        _showComingSoon(action);
    }
  }

  void _handleDrawerTap(String item) {
    Navigator.pop(context); // Close the drawer first.

    switch (item) {
      case 'Dashboard':
        setState(() => _selectedIndex = 0);
        break;
      case 'Inmates':
        _openInmates();
        break;
      case 'Visitors':
        _openVisitors();
        break;
      case 'Tracking':
        _openTracking();
        break;
      case 'Release Management':
        _openReleaseManagement();
        break;
      case 'Rehabilitation':
      case 'Staff Duty Roster':
      case 'Notifications':
        _showComingSoon(item);
        break;
      case 'Profile & Settings':
        _showProfile();
        break;
      case 'Sign Out':
        _logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String)>[
      (Icons.group_outlined, 'Inmates'),
      (Icons.person_add_alt_1_outlined, 'Visitors'),
      (Icons.description_outlined, 'Rehabilitation'),
      (Icons.track_changes, 'Tracking'),
      (Icons.calendar_month_outlined, 'Release Management'),
      (Icons.date_range_outlined, 'Duty Roster'),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: pageBackground,

      // Navigation drawer.
      drawer: Drawer(
        backgroundColor: deepGreen,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: deepGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.security,
                        color: deepGreen,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Malawi Prisons Service',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    _email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.dashboard_outlined, 'Dashboard'),
            _drawerItem(Icons.groups_outlined, 'Inmates'),
            _drawerItem(Icons.people_outline, 'Visitors'),
            _drawerItem(Icons.security_outlined, 'Rehabilitation'),
            _drawerItem(Icons.track_changes, 'Tracking'),
            _drawerItem(Icons.date_range_outlined, 'Staff Duty Roster'),
            _drawerItem(Icons.lock_open_outlined, 'Release Management'),
            _drawerItem(Icons.notifications_none, 'Notifications'),
            _drawerItem(Icons.person_outline, 'Profile & Settings'),
            const Divider(color: Colors.white24, height: 30),
            _drawerItem(Icons.logout, 'Sign Out'),
          ],
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green dashboard header.
              Container(
                color: deepGreen,
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () => _showComingSoon('Notifications'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                          onPressed: _showProfile,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Malawi Prisons Service',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Welcome, $_fullName',
                        style: const TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics cards.
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  color: deepGreen,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard(
                        'Total Inmates',
                        '$_totalInmates',
                        '+0.2%',
                        Icons.person_outline,
                      ),
                      _statCard(
                        'On Leave',
                        '$_onLeave',
                        'active',
                        Icons.verified_user_outlined,
                      ),
                      _statCard(
                        'Upcoming Releases',
                        '$_upcomingReleases',
                        'This week',
                        Icons.event_note,
                      ),
                      _statCard(
                        "Today's Visitors",
                        '$_todaysVisitors',
                        'scheduled',
                        Icons.groups_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // Quick actions.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                      children: [
                        for (final action in actions)
                          _quickAction(action.$1, action.$2),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Bottom navigation.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: deepGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
              break;
            case 1:
              _openInmates();
              break;
            case 2:
              _openTracking();
              break;
            case 3:
              setState(() => _selectedIndex = 3);
              _showProfile();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Inmates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    final selected = title == 'Dashboard' && _selectedIndex == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: fontFamily,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        onTap: () => _handleDrawerTap(title),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Icon(icon, size: 17, color: Colors.grey.shade500),
            ],
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
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

  Widget _quickAction(IconData icon, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _handleQuickAction(label),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: deepGreen, size: 26),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curved lower edge of the statistics header.
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

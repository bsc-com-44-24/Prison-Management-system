import 'package:material_ui/material_ui.dart';
import 'logout_screen.dart';

class PrisonMenuDrawer extends StatefulWidget {
  final Map<String, dynamic>? user;
  final ValueChanged<String>? onItemSelected;

  const PrisonMenuDrawer({
    super.key,
    this.user,
    this.onItemSelected,
  });

  @override
  State<PrisonMenuDrawer> createState() => _PrisonMenuDrawerState();
}

class _PrisonMenuDrawerState extends State<PrisonMenuDrawer> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _menuItemsForRole(String role) {
    final normalizedRole =
        role.trim().toLowerCase().replaceAll(RegExp(r'[_-]+'), ' ');
    final isAdmin = {
      'admin',
      'super admin',
      'system admin',
      'system administrator',
    }.contains(normalizedRole);

    final items = <Map<String, dynamic>>[
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/home'},
    ];

    if (isAdmin) {
      items.addAll([
        {
          'title': 'Manage Users',
          'icon': Icons.people,
          'route': '/manage-users',
        },
        {
          'title': 'Manage Prisons',
          'icon': Icons.account_balance,
          'route': '/manage-prisons',
        },
      ]);
    } else if (normalizedRole == 'commissioner' ||
        normalizedRole == 'prison commissioner') {
      items.addAll([
        {
          'title': 'Transfer Requests',
          'icon': Icons.swap_horiz,
          'route': '/commissioner-transfers',
        },
        {
          'title': 'Notifications',
          'icon': Icons.notifications_none,
          'route': '/commissioner-notifications',
        },
      ]);
    } else if (normalizedRole == 'duty officer' ||
        normalizedRole == 'prison officer') {
      items.addAll([
        {'title': 'Inmates', 'icon': Icons.people, 'route': '/inmates'},
        {
          'title': 'Staff Duty Roster',
          'icon': Icons.calendar_today,
          'route': '/staff',
        },
        {
          'title': 'Release Management',
          'icon': Icons.assignment_turned_in,
          'route': '/releases',
        },
      ]);
    } else if (normalizedRole == 'records officer' ||
        normalizedRole == 'record officer') {
      items.addAll([
        {'title': 'Inmates', 'icon': Icons.people, 'route': '/inmates'},
        {'title': 'Visitors', 'icon': Icons.badge, 'route': '/visitors'},
        {
          'title': 'Tracking',
          'icon': Icons.location_on_outlined,
          'route': '/tracking',
        },
      ]);
    } else if (normalizedRole == 'program facilitator') {
      items.add({
        'title': 'Rehabilitation',
        'icon': Icons.security,
        'route': '/rehabilitation',
      });
    }

    items.add({
      'title': 'Profile & Settings',
      'icon': Icons.person_outline,
      'route': '/profile',
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // Custom dark green color matching the design theme
    const Color primaryGreen = Color(0xFF2C4437);
    const Color selectedItemBackground = Color(0xFF455A50);

    // Extract user details dynamically from the user map with fallbacks
    final String fullName = widget.user?['full_name'] ?? 'User';
    final String email = widget.user?['email'] ?? 'email@prisons.gov.mw';
    final menuItems = _menuItemsForRole(widget.user?['role']?.toString() ?? '');

    return Drawer(
      backgroundColor: primaryGreen,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Logo, App Title, and Dynamic User Details
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Container using specified asset path
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/loggg.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // App Title
                  const Text(
                    'Malawi Prisons Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Dynamic Full Name from Logged-in Account
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Dynamic Email from Logged-in Account
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Scrollable Menu List
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          final title = item['title'] as String;
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          final onItemSelected = widget.onItemSelected;
                          if (onItemSelected != null) {
                            onItemSelected(title);
                          } else {
                            navigator.pushNamed(item['route'] as String);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedItemBackground
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Divider and Sign Out Button triggering the logout overlay dialog
            const Divider(color: Colors.white24, thickness: 1, height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Triggers the SignOutDialog overlay screen
                  SignOutDialog.show(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

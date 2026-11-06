import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'logout_screen.dart';

class PrisonMenuDrawer extends StatefulWidget {
  // Accept the logged-in user data map dynamically
  final Map<String, dynamic>? user;

  const PrisonMenuDrawer({Key? key, this.user}) : super(key: key);

  @override
  State<PrisonMenuDrawer> createState() => _PrisonMenuDrawerState();
}

class _PrisonMenuDrawerState extends State<PrisonMenuDrawer> {
  // Track the currently selected menu index
  int _selectedIndex = 0;

  // Fully typed list to resolve compiler errors
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Inmates', 'icon': Icons.people},
    {'title': 'Visitors', 'icon': Icons.badge},
    {'title': 'Rehabilitation', 'icon': Icons.security},
    {'title': 'Tracking', 'icon': Icons.location_on_outlined},
    {'title': 'Staff Duty Roster', 'icon': Icons.calendar_today},
    {'title': 'Release Management', 'icon': Icons.assignment_turned_in},
    {'title': 'Notifications', 'icon': Icons.notifications_none},
    {'title': 'Profile & Settings', 'icon': Icons.person_outline},
  ];

  @override
  Widget build(BuildContext context) {
    // Custom dark green color matching the design theme
    const Color primaryGreen = Color(0xFF2C4437);
    const Color selectedItemBackground = Color(0xFF455A50);

    // Extract user details dynamically from the user map with fallbacks
    final String fullName = widget.user?['full_name'] ?? 'User';
    final String email = widget.user?['email'] ?? 'email@prisons.gov.mw';

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
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
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
                          // Handle menu navigation actions here
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
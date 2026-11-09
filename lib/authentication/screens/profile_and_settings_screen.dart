import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import to allow navigation back to Dashboard
import 'logout_screen.dart'; // Import your separated dialog here

class ProfileSettingsScreen extends StatelessWidget {
  // Accept the dynamic user map from the login/dashboard flow
  final Map<String, dynamic>? user;

  const ProfileSettingsScreen({super.key, this.user});

  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032);
  static const String fontFamily = 'Roboto';

  @override
  Widget build(BuildContext context) {
    // Extract dynamic email and role, with clean fallback defaults
    final String email = user?['email'] ?? 'email@prisons.gov.mw';
    final String role = user?['role'] ?? 'System Administrator';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: deepGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            fontFamily: fontFamily,
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Profile Header Card with Dynamic Data
            Container(
              color: deepGreen,
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Email Display
                        Text(
                          email,
                          style: const TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Settings Options List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsOption(Icons.person_outline, 'Edit Profile', showDivider: true),
                        _buildSettingsOption(Icons.lock_outline, 'Change Password', showDivider: true),
                        _buildSettingsOption(Icons.notifications_none, 'Notification Settings', showDivider: true),
                        _buildSettingsOption(Icons.settings_outlined, 'App Settings', showDivider: true),
                        _buildSettingsOption(Icons.help_outline, 'Help & Support', showDivider: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Out Button Card invoking the imported dialog
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextButton.icon(
                      onPressed: () => SignOutDialog.show(context),
                      icon: const Icon(Icons.logout, color: maroonButton, size: 18),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: maroonButton,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: deepGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Inmates'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          // If 'Home' (index 0) is tapped, navigate to DashboardScreen carrying user data
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(user: user ?? {}),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54, size: 20),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {},
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
      ],
    );
  }
}
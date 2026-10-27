import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, Object?> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0;

  // Placeholder numbers: connect these to your data later.
  final int _totalInmates = 0;
  final int _onLeave = 0;
  final int _upcomingReleases = 0;
  final int _todaysVisitors = 0;

  static const _bg = Color(0xFFF4F5F3);

  void _soon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name coming soon')),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfile() {
    final u = widget.user;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: kGreen,
            child: Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text('${u['full_name']}',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${u['email']}'),
          Text('ID: ${u['officer_id']}  •  ${u['phone']}'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String)>[
      (Icons.groups_outlined, 'Inmates'),
      (Icons.how_to_reg_outlined, 'Visitors'),
      (Icons.menu_book_outlined, 'Rehabilitation'),
      (Icons.my_location, 'Tracking'),
      (Icons.event_available_outlined, 'Release\nMgmt'),
      (Icons.notifications_none, 'Notifications'),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Malawi prisons services',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Text('${widget.user['full_name']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('${widget.user['email']}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: _logout,
          ),
        ]),
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        // ---------- Header ----------
        SizedBox(
          height: 210,
          child: Stack(children: [
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(height: 210, color: kGreen),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_none,
                              color: Colors.white),
                          onPressed: () => _soon('Notifications'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.account_circle_outlined,
                              color: Colors.white),
                          onPressed: _showProfile,
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Malawi prisons services',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
              ),
            ),
          ]),
        ),

        // ---------- Stat cards ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Inmates',
                  value: '$_totalInmates',
                  caption: '+0.2%',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'On Leave',
                  value: '$_onLeave',
                  caption: 'active',
                  icon: Icons.verified_user_outlined,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _StatCard(
                  title: 'Upcoming\nReleases',
                  value: '$_upcomingReleases',
                  icon: Icons.event_note,
                  iconColor: Colors.red,
                  chip: 'This week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Today's Visitors",
                  value: '$_todaysVisitors',
                  caption: 'scheduled',
                  icon: Icons.groups_outlined,
                ),
              ),
            ]),
          ]),
        ),

        // ---------- Quick actions ----------
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final a in actions)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _soon(a.$2.replaceAll('\n', ' ')),
                  child: Container(
                    decoration: _cardDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(a.$1, size: 26, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(a.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ]),

      // ---------- Bottom navigation ----------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (i) {
          setState(() => _tab = i);
          if (i == 1) _soon('Inmates');
          if (i == 2) _soon('Reports');
          if (i == 3) _showProfile();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Inmates'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? caption;
  final String? chip;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.caption,
    this.chip,
    this.iconColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ),
            Icon(icon, size: 18, color: iconColor),
          ],
        ),
        const Spacer(),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(caption!,
                  style: const TextStyle(fontSize: 9, color: Colors.black45)),
            ),
          const Spacer(),
          if (chip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(chip!,
                  style: const TextStyle(fontSize: 9, color: Colors.red)),
            ),
        ]),
      ]),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width, h = s.height;
    return Path()
      ..lineTo(0, h * 0.80)
      ..cubicTo(w * 0.22, h * 0.98, w * 0.38, h * 0.55, w * 0.62, h * 0.72)
      ..cubicTo(w * 0.80, h * 0.84, w * 0.92, h * 0.95, w, h * 0.86)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

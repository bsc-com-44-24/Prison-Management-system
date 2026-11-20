import 'package:material_ui/material_ui.dart';

class PrisonOfficerDashboardScreen extends StatefulWidget {
  final Map<String, Object?> user;

  final VoidCallback? onDutyRoster;
  final VoidCallback? onReleaseProcess;
  final VoidCallback? onViewInmates;

  const PrisonOfficerDashboardScreen({
    super.key,
    required this.user,
    this.onDutyRoster,
    this.onReleaseProcess,
    this.onViewInmates,
  });

  @override
  State<PrisonOfficerDashboardScreen> createState() =>
      _PrisonOfficerDashboardScreenState();
}

class _PrisonOfficerDashboardScreenState
    extends State<PrisonOfficerDashboardScreen> {
  // Theme colours
  final Color deepGreen = const Color(0xFF344B3B);
  final Color maroon = const Color(0xFF7A2032);
  final Color backgroundColor = const Color(0xFFF4F5F3);

  // User information
  String get userName {
    return (widget.user['full_name'] ??
            widget.user['fullName'] ??
            widget.user['name'] ??
            widget.user['username'] ??
            widget.user['email'] ??
            'Prison Officer')
        .toString();
  }

  String get userRole {
    return (widget.user['role'] ??
            widget.user['user_role'] ??
            widget.user['userRole'] ??
            'Prison Officer')
        .toString();
  }

  String get prisonName {
    return (widget.user['prison_name'] ??
            widget.user['prisonName'] ??
            'Assigned Prison')
        .toString();
  }

  String get userEmail {
    return (widget.user['email'] ?? 'No email provided').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
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
                      'Manage your prison operations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        22,
      ),
      decoration: BoxDecoration(
        color: deepGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Navigation menu will be connected soon.',
                      ),
                    ),
                  );
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notifications will be connected soon.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            prisonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // QUICK ACTIONS
  // --------------------------------------------------

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.12,
      children: [
        _buildQuickAction(
          title: 'Duty Roster',
          description: 'View shifts and assign duty to staff',
          icon: Icons.calendar_month_outlined,
          onTap: widget.onDutyRoster,
        ),
        _buildQuickAction(
          title: 'Release Process',
          description: 'Process inmates reaching their release date',
          icon: Icons.assignment_outlined,
          onTap: widget.onReleaseProcess,
        ),
        _buildQuickAction(
          title: 'View Inmates',
          description: 'View and manage inmates',
          icon: Icons.groups_outlined,
          onTap: widget.onViewInmates,
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String description,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () => _openAction(onTap, title),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
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
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ACTION HANDLING
  // --------------------------------------------------

  void _openAction(
    VoidCallback? callback,
    String actionName,
  ) {
    if (callback != null) {
      callback();
      return;
    }

    final route = switch (actionName) {
      'Duty Roster' => '/staff',
      'Release Process' || 'Release Management' => '/releases',
      _ => null,
    };
    if (route != null) {
      Navigator.pushNamed(context, route);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$actionName screen will be connected soon.',
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PROFILE
  // --------------------------------------------------

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: deepGreen.withValues(alpha: 0.10),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: deepGreen,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userEmail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userRole,
                style: TextStyle(
                  color: deepGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prisonName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../models/tracking_model.dart';
import '../../visitor_management/screens/visitor_list_screen.dart';
import '../../Inmate_management/screens/inmate_list_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _selectedTab = 'Visitors';

  // Sample tracking records.
  // These are mock records, not database records.
  final List<TrackingItem> _trackingItems = [
    // Visitors
    TrackingItem(
      title: 'Grace Moyo',
      subtitle: 'Sister',
      dateOrDuration: '10 Oct 2026 • 10:00',
      status: 'Approved',
      detailInfo: 'ID: MP-98214 • Inmate: John Moyo',
      category: 'Visitors',
    ),
    TrackingItem(
      title: 'James Phiri',
      subtitle: 'Brother',
      dateOrDuration: '11 Oct 2026 • 14:00',
      status: 'Pending',
      detailInfo: 'ID: MP-33102 • Inmate: David Phiri',
      category: 'Visitors',
    ),
    TrackingItem(
      title: 'Beatrice Nkhata',
      subtitle: 'Wife',
      dateOrDuration: '12 Oct 2026 • 09:00',
      status: 'Approved',
      detailInfo: 'ID: MP-55411 • Inmate: Peter Nkhata',
      category: 'Visitors',
    ),
    TrackingItem(
      title: 'Daniel Chisala',
      subtitle: 'Friend',
      dateOrDuration: '14 Oct 2026 • 11:00',
      status: 'Rejected',
      detailInfo: 'ID: MP-11029 • Inmate: Samuel Chisala',
      category: 'Visitors',
    ),

    // Inmates
    TrackingItem(
      title: 'John Moyo',
      subtitle: 'Block B • Cell #14',
      dateOrDuration: 'Sentence: 4 Years',
      status: 'Active',
      detailInfo: 'ID: MP/00189 • Release: Oct 2030',
      category: 'Inmate',
    ),
    TrackingItem(
      title: 'David Phiri',
      subtitle: 'Block A • Cell #03',
      dateOrDuration: 'Sentence: 2 Years',
      status: 'Active',
      detailInfo: 'ID: MP/00214 • Release: Nov 2028',
      category: 'Inmate',
    ),
    TrackingItem(
      title: 'Peter Nkhata',
      subtitle: 'Block C • Cell #22',
      dateOrDuration: 'Sentence: 5 Years',
      status: 'Active',
      detailInfo: 'ID: MP/00305 • Release: Jan 2031',
      category: 'Inmate',
    ),

    // Activities
    TrackingItem(
      title: 'To Workshop',
      subtitle: 'Woodwork & Crafts Facility',
      dateOrDuration: '10 Oct 2026 • 08:30',
      status: 'Completed',
      detailInfo: 'Escort: Officer Banda',
      category: 'Activities',
    ),
    TrackingItem(
      title: 'To Clinic',
      subtitle: 'Prison Medical Ward - Checkup',
      dateOrDuration: '07 Oct 2026 • 14:15',
      status: 'Logged',
      detailInfo: 'Attending: Dr. Phiri',
      category: 'Activities',
    ),
  ];

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // Open Inmate Management.
  // Selecting an inmate there should open that inmate's details.
  void _goToInmates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InmateListScreen(),
      ),
    );
  }

  // Open Visitor Management.
  void _goToVisitors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VisitorListScreen(),
      ),
    );
  }

  // Handle the Tracking category tabs.
  void _onTabSelected(String tab) {
    if (tab == 'Visitors') {
      _goToVisitors();
    } else if (tab == 'Inmate') {
      _goToInmates();
    } else {
      // Activities remains on the Tracking screen.
      setState(() {
        _selectedTab = 'Activities';
      });
    }
  }

  void _goToProfile() {
    _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _trackingItems
        .where((item) => item.category == _selectedTab)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: const Color(0xFF344B3B),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add tracking record',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Adding tracking records has not been implemented yet.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tracking category tabs.
          Container(
            color: const Color(0xFF344B3B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Visitors', 'Activities', 'Inmate'].map((tab) {
                final isSelected = _selectedTab == tab;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabSelected(tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7A1F2D)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tracking records.
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('No tracking records found.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      Color badgeBg = const Color(0xFFDCFCE7);
                      Color badgeFg = const Color(0xFF166534);

                      if (item.status == 'Pending') {
                        badgeBg = const Color(0xFFFEF3C7);
                        badgeFg = const Color(0xFF92400E);
                      } else if (item.status == 'Rejected') {
                        badgeBg = const Color(0xFFFEE2E2);
                        badgeFg = const Color(0xFF7A1F2D);
                      }

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        const Color(0xFFF1F5F9),
                                    child: Icon(
                                      _selectedTab == 'Visitors'
                                          ? Icons.person_outline
                                          : _selectedTab == 'Inmate'
                                              ? Icons.badge_outlined
                                              : Icons.event_note_outlined,
                                      size: 18,
                                      color: const Color(0xFF344B3B),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        color: badgeFg,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 42),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.subtitle,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Divider(height: 16),
                                    Text(
                                      item.dateOrDuration,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.detailInfo,
                                      style: const TextStyle(
                                        color: Color(0xFF7A1F2D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF7A1F2D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              _goToHome();
              break;
            case 1:
              _goToInmates();
              break;
            case 2:
              // Already on Tracking.
              break;
            case 3:
              _goToProfile();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
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
}

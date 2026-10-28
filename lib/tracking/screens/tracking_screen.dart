import 'package:flutter/material.dart';
import '../models/tracking_model.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _selectedTab = 'Visitors';

  // Mock tracking data conforming to project constraints (no restricted terms)
  final List<TrackingItem> _trackingItems = [
    TrackingItem(
      title: 'To Workshop',
      subtitle: 'Woodwork & Crafts Facility',
      date: '10 Oct 2026 • 08:30',
      status: 'Completed',
      detailInfo: 'Escort: Officer Banda',
      category: 'Visitors',
    ),
    TrackingItem(
      title: 'Back to Cell',
      subtitle: 'Block B • Cell #14',
      date: '09 Oct 2026 • 16:20',
      status: 'Logged',
      detailInfo: 'Routine Roll Call',
      category: 'Visitors',
    ),
    TrackingItem(
      title: 'Court Appearance',
      subtitle: 'High Court Lilongwe',
      date: '08 Oct 2026 • 09:00',
      status: 'Official Hearing',
      detailInfo: 'Escort Unit',
      category: 'Inmates',
    ),
    TrackingItem(
      title: 'To Clinic',
      subtitle: 'Medical Ward • Checkup',
      date: '07 Oct 2026 • 14:15',
      status: 'Logged',
      detailInfo: 'Dr. Phiri',
      category: 'Activities',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _trackingItems
        .where((item) => item.category == _selectedTab)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: const Color(0xFF344B3B), // Official Dark Green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search logic if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Filter Tabs (Visitors, Activities, Inmates)
          Container(
            color: const Color(0xFF344B3B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Visitors', 'Activities', 'Inmates'].map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7A1F2D) // Maroon Active Tab
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
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

          // List of Tracking Entries
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.status == 'Official Hearing'
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: item.status == 'Official Hearing'
                                      ? const Color(0xFF7A1F2D)
                                      : const Color(0xFF166534),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.date,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item.detailInfo,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
      // Footer Navigation with "Tracking" replacing "Reports"
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Index corresponding to Tracking tab
        selectedItemColor: const Color(0xFF7A1F2D), // Maroon
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Handle bottom navigation switching
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
            icon: Icon(Icons.analytics_outlined),
            label: 'Tracking', // Updated from Reports to Tracking
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
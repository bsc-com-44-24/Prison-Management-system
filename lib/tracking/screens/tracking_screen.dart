import 'package:flutter/material.dart';
import '../models/tracking_model.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _selectedTab = 'Visitors';

  // Comprehensive mock data covering Issue #9 requirements
  final List<TrackingItem> _trackingItems = [
    // Visitors Tab Data (matching Figma design)
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

    // Inmate Tab Data (matching Inmate form metrics & Issue #9)
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

    // Activities Tab Data (Welfare & Daily operations)
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

  @override
  Widget build(BuildContext context) {
    // Note: Figma labels tab as 'Inmate' (singular) or 'Inmates'
    final filteredItems = _trackingItems.where((item) {
      if (_selectedTab == 'Inmate') {
        return item.category == 'Inmate';
      }
      return item.category == _selectedTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: const Color(0xFF344B3B), // Dark Green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Action to add new record matching current tab
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Filter Tabs: Visitors, Activities, Inmate
          Container(
            color: const Color(0xFF344B3B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Visitors', 'Activities', 'Inmate'].map((tab) {
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

          // Dynamic List of Tracking Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                // Determine badge background and text color based on status
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFF1F5F9),
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
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                             const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.dateOrDuration,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    item.detailInfo.contains('•') 
                                        ? item.detailInfo.split('•')[0].trim() 
                                        : item.detailInfo,
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.detailInfo.contains('•')) ...[
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item.detailInfo.split('•')[1].trim(),
                                    style: const TextStyle(
                                      color: Color(0xFF7A1F2D), // Maroon brand color
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
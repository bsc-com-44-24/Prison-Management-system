import 'package:flutter/material.dart';
import '../models/notification_model.dart';
// Adjust imports based on your project structure

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Read'
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    // TODO: Replace with your actual database/API service call (e.g., SQFlite or NestJS backend)
    // e.g., final data = await DatabaseHelper.instance.getNotifications();
    await Future.delayed(const Duration(milliseconds: 600)); // simulated network/DB latency

    setState(() {
      _notifications = []; // Loaded dynamically from backend/database
      _isLoading = false;
    });
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'Read') {
      return _notifications.where((n) => n.isRead).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B2E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Unread, Read)
          Container(
            color: primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: ['All', 'Unread', 'Read'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white24,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryGreen : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Notification List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                : _filteredNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No notification records found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredNotifications.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final item = _filteredNotifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: item.isHighPriority ? Colors.red.shade50 : primaryGreen.withValues(alpha: 0.1),
                                child: Icon(
                                  _getCategoryIcon(item.category),
                                  color: item.isHighPriority ? Colors.red : primaryGreen,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    item.timeAgo,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  item.message,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ),
                              onTap: () {
                                // Mark as read logic
                                setState(() {
                                  item.isRead = true;
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Consistent Bottom Navigation Bar matching Visitor Screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Adjust index according to active screen
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Inmates'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          // Handle bottom nav routing consistent with visitor/dashboard screens
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'release':
        return Icons.schedule;
      case 'visitor':
        return Icons.person_add_outlined;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'rehabilitation':
        return Icons.refresh;
      default:
        return Icons.notifications_outlined;
    }
  }
}
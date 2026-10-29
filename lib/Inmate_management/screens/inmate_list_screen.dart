import 'package:flutter/material.dart';

import '../../database/db_helper.dart';
import '../models/inmate_model.dart';
import 'new_inmate_screen.dart';
import 'inmate_detail_screen.dart';

class InmateListScreen extends StatefulWidget {
  const InmateListScreen({super.key});

  @override
  State<InmateListScreen> createState() => _InmateListScreenState();
}

class _InmateListScreenState extends State<InmateListScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  List<InmateModel> inmates = [];

  @override
  void initState() {
    super.initState();
    _loadInmates();
  }

  // Load inmate records from the database.
  void _loadInmates() {
    if (!mounted) return;

    setState(() {
      inmates = DBHelper.getInmates();
    });
  }

  // Navigate to the dashboard.
  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // Navigate to the Tracking screen.
  void _goToTracking() {
    Navigator.pushNamed(context, '/tracking');
  }

  // Profile currently returns to the dashboard.
  void _goToProfile() {
    _goToHome();
  }

  // Handle the back arrow.
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<InmateModel> filteredInmates = inmates.where((inmate) {
      bool matchesFilter = true;

      if (selectedFilter == 'Male') {
        matchesFilter = inmate.gender == 'Male';
      } else if (selectedFilter == 'Female') {
        matchesFilter = inmate.gender == 'Female';
      }

      final bool matchesSearch =
          inmate.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          inmate.id.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Header
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _goBack,
          tooltip: 'Back',
        ),
        title: const Text(
          'Inmates',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Main content
      body: Column(
        children: [
          // Search field
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),

          // Gender filters
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: ['All', 'Male', 'Female'].map((filter) {
                final bool isSelected = selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: const Color(0xFF7A1F2D),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Inmate list
          Expanded(
            child: filteredInmates.isEmpty
                ? const Center(
                    child: Text(
                      'No inmate records found.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredInmates.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemBuilder: (context, index) {
                      final inmate = filteredInmates[index];
                      final bool isActive = inmate.status == 'Active';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          // Open inmate details.
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InmateDetailScreen(inmate: inmate),
                              ),
                            );

                            if (mounted) {
                              _loadInmates();
                            }
                          },

                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),

                          title: Text(
                            inmate.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                inmate.id,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${inmate.gender} • ${inmate.age} yrs • ${inmate.facility}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Inmate status
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              inmate.status,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Register a new inmate.
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A1F2D),
        tooltip: 'Add inmate',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewInmateScreen(),
            ),
          );

          if (mounted) {
            _loadInmates();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF7A1F2D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          switch (index) {
            case 0:
              _goToHome();
              break;

            case 1:
              // Already on the Inmates screen.
              break;

            case 2:
              _goToTracking();
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
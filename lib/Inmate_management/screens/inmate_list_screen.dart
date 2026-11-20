import 'package:material_ui/material_ui.dart';

import '../../database/db_helper.dart';
import '../models/inmate_model.dart';
import 'new_inmate_screen.dart';
import 'inmate_detail_screen.dart';

class InmateListScreen extends StatefulWidget {
  final String
      currentUserRole; // Pass the logged-in user's role (defaults to 'Record Officer' for testing)

  const InmateListScreen({super.key, this.currentUserRole = 'Record Officer'});

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
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
    final bool isRecordOfficer = widget.currentUserRole == 'Record Officer';

    final List<InmateModel> filteredInmates = inmates.where((inmate) {
      bool matchesFilter = true;
      if (selectedFilter == 'Male') {
        matchesFilter = inmate.gender == 'Male';
      } else if (selectedFilter == 'Female') {
        matchesFilter = inmate.gender == 'Female';
      }

      // Search by Name, ID, or Prison Facility
      final query = searchQuery.toLowerCase();
      final bool matchesSearch =
          inmate.fullName.toLowerCase().contains(query) ||
              inmate.id.toLowerCase().contains(query) ||
              inmate.facility.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Header
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                hintText: 'Search by name, ID, or prison...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final inmate = filteredInmates[index];
                      final bool isActive = inmate.status == 'Active';
                      final bool hasPhotos = inmate.photos.isNotEmpty;

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

                          // Display captured inmate photo (or default icon if none)
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: hasPhotos
                                    ? MemoryImage(inmate.photos.first)
                                    : null,
                                child: !hasPhotos
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              if (inmate.photos.length > 1)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF344B3B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${inmate.photos.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                                '${inmate.gender} • ${inmate.age} yrs',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Highlighted Prison Facility row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 14,
                                    color: Color(0xFF344B3B),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      inmate.facility,
                                      style: const TextStyle(
                                        color: Color(0xFF344B3B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Inmate status (Active vs Released)
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive ? Colors.green[50] : Colors.red[50],
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

      // Register a new inmate (Restricted to Record Officer only)
      floatingActionButton: isRecordOfficer
          ? FloatingActionButton(
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
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

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

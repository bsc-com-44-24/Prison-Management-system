import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/inmate_model.dart';
import 'new_inmate_screen.dart';
import 'inmate_detail_screen.dart';

class InmateListScreen extends StatefulWidget {
  const InmateListScreen({Key? key}) : super(key: key);

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

  void _loadInmates() {
    setState(() {
      inmates = DBHelper.getInmates();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<InmateModel> filteredInmates = inmates.where((inmate) {
      bool matchesFilter = true;
      if (selectedFilter == 'Male') matchesFilter = inmate.gender == 'Male';
      if (selectedFilter == 'Female') matchesFilter = inmate.gender == 'Female';

      bool matchesSearch =
          inmate.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          inmate.id.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF344b3b), // Dark Green Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Inmates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Actions removed to clear the search icon from the header
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              children: ['All', 'Male', 'Female'].map((filter) {
                bool isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: const Color(0xFF7a1f2d), // Burgundy Accent
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (bool selected) =>
                        setState(() => selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredInmates.isEmpty
                ? const Center(
                    child: Text(
                      'No inmate records found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredInmates.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      final inmate = filteredInmates[index];
                      bool isActive = inmate.status == 'Active';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InmateDetailScreen(inmate: inmate),
                              ),
                            );
                            _loadInmates();
                          },
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7a1f2d), // Burgundy Button
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewInmateScreen()),
          );
          _loadInmates();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF7a1f2d),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Inmates'),
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

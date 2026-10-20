import 'package:flutter/material.dart';

import '../../models/inmate_model.dart';
import 'add_inmate_screen.dart';
import 'inmate_detail_screen.dart';

class InmateListScreen extends StatefulWidget {
  const InmateListScreen({super.key});

  @override
  State<InmateListScreen> createState() => _InmateListScreenState();
}

class _InmateListScreenState extends State<InmateListScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  int _currentIndex = 1; // 1 is 'Inmates' based on your bottom nav design

  // In-memory list matching your design mockups
  final List<InmateModel> inmates = [
    InmateModel(
      id: 'MP/00123',
      fullName: 'Moses Banda',
      gender: 'Male',
      age: 32,
      dateOfBirth: '1993-04-12',
      nationality: 'Malawian',
      facility: 'Lilongwe Prison',
      offenceCategory: 'Theft',
      sentenceYears: 5,
      releaseDate: '2028-04-12',
      status: 'Active',
    ),
    InmateModel(
      id: 'MP/00134',
      fullName: 'Aisha Chirwa',
      gender: 'Female',
      age: 28,
      dateOfBirth: '1998-09-20',
      nationality: 'Malawian',
      facility: 'Zomba Central',
      offenceCategory: 'Fraud',
      sentenceYears: 3,
      releaseDate: '2027-09-20',
      status: 'Active',
    ),
    InmateModel(
      id: 'MP/00125',
      fullName: 'James Phiri',
      gender: 'Male',
      age: 45,
      dateOfBirth: '1981-02-15',
      nationality: 'Malawian',
      facility: 'Maula Prison',
      offenceCategory: 'Assault',
      sentenceYears: 4,
      releaseDate: '2029-02-15',
      status: 'Active',
    ),
    InmateModel(
      id: 'MP/00126',
      fullName: 'Simon Nkhata',
      gender: 'Male',
      age: 37,
      dateOfBirth: '1989-11-04',
      nationality: 'Malawian',
      facility: 'Chichiri Prison',
      offenceCategory: 'Robbery',
      sentenceYears: 2,
      releaseDate: '2026-11-04',
      status: 'Under Review',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter and search logic
    List<InmateModel> filteredInmates = inmates.where((inmate) {
      bool matchesFilter = true;
      if (selectedFilter == 'Male') matchesFilter = inmate.gender == 'Male';
      if (selectedFilter == 'Female') matchesFilter = inmate.gender == 'Female';
      if (selectedFilter == 'Remand') {
        matchesFilter = inmate.status == 'Under Review';
      }

      bool matchesSearch =
          inmate.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          inmate.id.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C4A3E), // Forest Green Header
        title: const Text(
          'Inmates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar Container
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF2C4A3E),
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

          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: ['All', 'Male', 'Female', 'Remand'].map((filter) {
                bool isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6B1D2F), // Burgundy Accent
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Inmates List View
          Expanded(
            child: ListView.builder(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InmateDetailScreen(inmate: inmate),
                        ),
                      );
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
                          '${inmate.gender} • ${inmate.age} years • ${inmate.facility}',
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
                        color: isActive ? Colors.green[50] : Colors.red[50],
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
                          color: isActive ? Colors.green[700] : Colors.red[700],
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
        backgroundColor: const Color(0xFF6B1D2F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final newInmate = await Navigator.push<InmateModel>(
            context,
            MaterialPageRoute(builder: (context) => const AddInmateScreen()),
          );

          if (newInmate != null) {
            setState(() {
              inmates.add(newInmate);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inmate record added successfully!'),
              ),
            );
          }
        },
      ),
      // Footer / Bottom Navigation Bar matching your design mockups
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6B1D2F), // Burgundy when selected
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // You can wire up navigation to Home, Reports, or Profile screens here when ready
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Inmates'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
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

import 'package:flutter/material.dart';

class RehabilitationScreen extends StatefulWidget {
  const RehabilitationScreen({super.key});

  @override
  State<RehabilitationScreen> createState() => _RehabilitationScreenState();
}

class _RehabilitationScreenState extends State<RehabilitationScreen> {
  int _selectedTab = 0; // 0 for Programs, 1 for Attendance

  // Properly typed list to avoid top-level inference and naming warnings
  final programs = [
    {
      'title': 'Vocational Training',
      'category': 'Carpentry, Tailoring, Metalwork',
      'participants': '12 participants',
    },
    {
      'title': 'Counselling & Psycho-Social',
      'category': 'Substance abuse & anger management',
      'participants': '8 participants',
    },
    {
      'title': 'Education & Literacy',
      'category': 'Primary, secondary & adult literacy',
      'participants': '15 participants',
    },
    {
      'title': 'Life Skills & Civic Education',
      'category': 'Financial literacy & reintegration prep',
      'participants': '10 participants',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B), // Dark Green Header
        title: const Text(
          'Rehabilitation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Custom Segmented Tab Bar matching Figma (Burgundy active tab)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? const Color(0xFF7A1F2D)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Programs',
                        style: TextStyle(
                          color: _selectedTab == 0
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? const Color(0xFF7A1F2D)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          color: _selectedTab == 1
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content depending on tab selection
          Expanded(
            child: _selectedTab == 0
                ? _buildProgramsList()
                : _buildAttendanceView(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final prog = programs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF344B3B).withValues(alpha: 0.1),
              child: const Icon(Icons.work_outline, color: Color(0xFF344B3B)),
            ),
            title: Text(
              prog['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prog['category']!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF344B3B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prog['participants']!,
                      style: const TextStyle(
                        color: Color(0xFF344B3B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              _showAssignModal(context, prog['title']!);
            },
          ),
        );
      },
    );
  }

  void _showAssignModal(BuildContext context, String programTitle) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                programTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF344B3B),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Assign inmates to this activity:'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F2D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Successfully assigned inmate to $programTitle!',
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm Assignment'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceView() {
    return const Center(
      child: Text(
        'Attendance Tracking Module\n(Mark daily session logs here)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

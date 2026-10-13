import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../widgets/roster_card.dart';

class StaffRosterScreen extends StatefulWidget {
  const StaffRosterScreen({super.key});

  @override
  State<StaffRosterScreen> createState() => _StaffRosterScreenState();
}

class _StaffRosterScreenState extends State<StaffRosterScreen> {
  final List<ShiftModel> _shifts = [
    ShiftModel(
      shiftName: 'Morning Shift',
      timeRange: '06:00 - 14:00',
      status: 'Active Now',
      supervisorName: 'Officer M. Banda',
      supervisorRole: 'Supervisor',
      assignedLocation: 'Maula Yard & Perimeter',
      officerCount: 6,
    ),
    ShiftModel(
      shiftName: 'Afternoon Shift',
      timeRange: '14:00 - 22:00',
      status: 'Scheduled',
      supervisorName: 'Officer T. Phiri',
      supervisorRole: 'Guard Lead',
      assignedLocation: 'Standard Perimeter',
      officerCount: 5,
    ),
    ShiftModel(
      shiftName: 'Night Shift',
      timeRange: '22:00 - 06:00',
      status: 'High Alert',
      supervisorName: 'Officer L. Nkhata',
      supervisorRole: 'Night Guard Lead',
      assignedLocation: 'Armed Watch & Gates',
      officerCount: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Duty Roster'),
        backgroundColor: const Color(0xFF2C4A3E), // Dark Forest Green from Figma
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2C4A3E),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 18, color: Color(0xFF2C4A3E)),
                  SizedBox(width: 8),
                  Text(
                    "Mon, 13 Oct 2026",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C4A3E)),
                  ),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF2C4A3E)),
                ],
              ),
            ),
          ),
          // Top Statistics Summary Tiles (Matching Figma)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatTile("TOTAL STAFF", "15 Officers"),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildStatTile("CURRENT SHIFT", "Morning", valueColor: const Color(0xFF991B1B)),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildStatTile("ATTENDANCE", "100%"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Shift Roster List
          Expanded(
            child: ListView.builder(
              itemCount: _shifts.length,
              itemBuilder: (context, index) {
                return RosterCard(shift: _shifts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, {Color valueColor = const Color(0xFF1E293B)}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
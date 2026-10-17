import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../widgets/roster_card.dart';

class StaffRosterScreen extends StatefulWidget {
  const StaffRosterScreen({super.key});

  @override
  State<StaffRosterScreen> createState() => _StaffRosterScreenState();
}

class _StaffRosterScreenState extends State<StaffRosterScreen> {
  // Mock data list made modifiable so we can add new entries dynamically
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

  // Explicitly typed GlobalKey to prevent null casting errors
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _shiftNameController = TextEditingController();
  final TextEditingController _timeRangeController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  String _selectedStatus = 'Scheduled';

  @override
  void dispose() {
    _shiftNameController.dispose();
    _timeRangeController.dispose();
    _supervisorController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _countController.dispose();
    super.dispose();
  }

  // Method to open the interactive Shift Assignment Dialog
  void _showAssignShiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign New Shift', style: TextStyle(color: Color(0xFF2C4A3E), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _shiftNameController,
                    decoration: const InputDecoration(labelText: 'Shift Name (e.g. Morning Shift)'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter shift name' : null,
                  ),
                  TextFormField(
                    controller: _timeRangeController,
                    decoration: const InputDecoration(labelText: 'Time Range (e.g. 06:00 - 14:00)'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter time range' : null,
                  ),
                  TextFormField(
                    controller: _supervisorController,
                    decoration: const InputDecoration(labelText: 'Supervisor Name (e.g. Officer K. Banda)'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter supervisor name' : null,
                  ),
                  TextFormField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Supervisor Role (e.g. Guard Lead)'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter role' : null,
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Assigned Location (e.g. Block A)'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter location' : null,
                  ),
                  TextFormField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Number of Officers'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter officer count' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Active Now', 'Scheduled', 'High Alert'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C4A3E), foregroundColor: Colors.white),
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  setState(() {
                    _shifts.add(
                      ShiftModel(
                        shiftName: _shiftNameController.text,
                        timeRange: _timeRangeController.text,
                        status: _selectedStatus,
                        supervisorName: _supervisorController.text,
                        supervisorRole: _roleController.text,
                        assignedLocation: _locationController.text,
                        officerCount: int.tryParse(_countController.text) ?? 1,
                      ),
                    );
                  });
                  // Clear controllers and close dialog
                  _shiftNameController.clear();
                  _timeRangeController.clear();
                  _supervisorController.clear();
                  _roleController.clear();
                  _locationController.clear();
                  _countController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Shift'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Duty Roster'),
        backgroundColor: const Color(0xFF2C4A3E),
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
          // Top Statistics Summary Tiles
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatTile("TOTAL STAFF", "${_shifts.length * 5} Officers"),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildStatTile("TOTAL SHIFTS", "${_shifts.length} Active"),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                _buildStatTile("ATTENDANCE", "100%"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Action Bar with Working Assign Shift Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shift Schedule Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
                ElevatedButton.icon(
                  onPressed: () => _showAssignShiftDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Assign Shift'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C4A3E), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
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
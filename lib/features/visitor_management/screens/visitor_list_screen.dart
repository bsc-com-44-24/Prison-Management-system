import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../services/visitor_database.dart';
import 'visitor_details_screen.dart'; // Safely linked to your new sub-file

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  int _currentNavIndex = 0; 
  List<Visitor> _visitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    try {
      final visitors = await VisitorDatabase.instance.getVisitors();
      if (!mounted) return;
      setState(() {
        _visitors = visitors;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load visitors: $e')),
      );
    }
  }

  void _openAddVisitorForm() async {
    final shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddVisitorScreen(),
      ),
    );

    if (shouldRefresh == true) {
      _loadVisitors();
    }
  }

  Future<void> _updateVisitorStatus(Visitor visitor, String status) async {
    if (visitor.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This visitor has no database ID.')),
      );
      return;
    }
    try {
      await VisitorDatabase.instance.updateVisitorStatus(visitor.id!, status);
      if (!mounted) return;
      await _loadVisitors();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Visitor status updated to $status.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update visitor status: $e')),
      );
    }
  }

  // Calls the external details widget layout directly on tap
  void _openDetailsWindow(BuildContext context, Visitor visitor) {
    showDialog(
      context: context,
      builder: (context) => VisitorDetailsScreen(
        visitor: visitor,
        onApprove: () => _updateVisitorStatus(visitor, 'Approved'),
        onDecline: () => _updateVisitorStatus(visitor, 'Declined'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        elevation: 0,
        title: const Text(
          'Visitors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            onPressed: _openAddVisitorForm,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visitors.isEmpty
              ? const Center(child: Text('No visitor records found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = _visitors[index];
                    
                    final bool isApproved = visitor.status == 'Approved';
                    final bool isPending = visitor.status == 'Pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDetailsWindow(context, visitor), 
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8EFEA),
                            child: Icon(Icons.person, color: Color(0xFF344B3B)),
                          ),
                          title: Text(
                            visitor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(visitor.relationship),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? const Color(0xFFEAF6EE)
                                  : isPending
                                      ? const Color(0xFFFFF9E6)
                                      : const Color(0xFFFCEBEB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              visitor.status,
                              style: TextStyle(
                                color: isApproved
                                    ? const Color(0xFF2E7D32)
                                    : isPending
                                        ? const Color(0xFFF57C00)
                                        : const Color(0xFF7A1F2D),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: 0, 
        selectedItemColor: Colors.grey, // Forced grey styling
        unselectedItemColor: Colors.grey, 
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: Colors.grey),
        unselectedLabelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            activeIcon: Icon(Icons.home_outlined, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, color: Colors.grey),
            activeIcon: Icon(Icons.people_outline, color: Colors.grey),
            label: 'Inmates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed, color: Colors.grey), // Target crosshair icon
            activeIcon: Icon(Icons.gps_fixed, color: Colors.grey),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            activeIcon: Icon(Icons.person_outline, color: Colors.grey),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({super.key});

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _inmateController = TextEditingController();
  final _purposeController = TextEditingController();
  final _belongingsController = TextEditingController();

  bool _hasBelongings = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    _inmateController.dispose();
    _purposeController.dispose();
    _belongingsController.dispose();
    super.dispose();
  }

  Future<void> _saveVisitor() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the visitor full name.')),
      );
      return;
    }

    final visitor = Visitor(
      name: name,
      idNumber: _idController.text.trim(),
      phone: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
      inmateName: _inmateController.text.trim(),
      purpose: _purposeController.text.trim(),
      belongings: _hasBelongings 
          ? (_belongingsController.text.trim().isEmpty ? 'Yes' : _belongingsController.text.trim())
          : 'None',
      status: 'Pending',
      visitDateTime: DateTime.now(),
    );

    try {
      await VisitorDatabase.instance.insertVisitor(visitor);
      if (!mounted) return;
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor record saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save visitor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: const Color(0xFFF4F6F4),
appBar: AppBar(
backgroundColor: const Color(0xFF344B3B),
elevation: 0,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
onPressed: () => Navigator.pop(context),
),
title: const Text(
'Record Visitor Details',
style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
),
centerTitle: true,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
TextField(
controller: _nameController,
decoration: const InputDecoration(
labelText: 'Visitor Full Name',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 12),
TextField(
controller: _idController,
decoration: const InputDecoration(
labelText: 'National ID Number',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 12),
TextField(
controller: _phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: 'Contact Phone Number',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 12),
TextField(
controller: _relationshipController,
decoration: const InputDecoration(
labelText: 'Relationship to Inmate',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 12),
TextField(
controller: _inmateController,
decoration: const InputDecoration(
labelText: 'Inmate Being Visited',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 12),
TextField(
controller: _purposeController,
decoration: const InputDecoration(
labelText: 'Purpose of Visit',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 16),
const Text(
'Are there any Checked Belongings / Items Left?',
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344B3B)),
),
const SizedBox(height: 8),
Row(
children: [
Expanded(
child: OutlinedButton(
style: OutlinedButton.styleFrom(
backgroundColor: _hasBelongings ? const Color(0xFF344B3B) : Colors.white,
side: const BorderSide(color: Color(0xFF344B3B)),
),
onPressed: () => setState(() => _hasBelongings = true),
child: Text('Yes', style: TextStyle(color: _hasBelongings ? Colors.white : const Color(0xFF344B3B))),
),
),
const SizedBox(width: 12),
Expanded(
child: OutlinedButton(
style: OutlinedButton.styleFrom(
backgroundColor: !_hasBelongings ? const Color(0xFF344B3B) : Colors.white,
side: const BorderSide(color: Color(0xFF344B3B)),
),
onPressed: () => setState(() => _hasBelongings = false),
child: Text('No', style: TextStyle(color: !_hasBelongings ? Colors.white : const Color(0xFF344B3B))),
),
),
],
),
if (_hasBelongings) ...[
const SizedBox(height: 12),
TextField(
controller: _belongingsController,
decoration: const InputDecoration(
labelText: 'Specify Belongings / Items details',
border: OutlineInputBorder(),
filled: true,
fillColor: Colors.white,
),
),
],
const SizedBox(height: 28),
SizedBox(
width: double.infinity,
height: 48,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF7A1F2D),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
onPressed: _saveVisitor,
child: const Text(
'Save',
style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
),
),
),
],
),
),
);
}
}
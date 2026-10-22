import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../services/visitor_database.dart';

class VisitorListScreen extends StatefulWidget {
const VisitorListScreen({super.key});

@override
State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
String _activeTab = 'Upcoming';
String _searchQuery = '';

List<Visitor> _visitors = [];
bool _isLoading = true;

// Form controllers
final _nameController = TextEditingController();
final _idController = TextEditingController();
final _phoneController = TextEditingController();
final _relationshipController = TextEditingController();
final _inmateController = TextEditingController();
final _purposeController = TextEditingController();
final _belongingsController = TextEditingController();

@override
void initState() {
super.initState();
_loadVisitors();
}

// Load visitors saved in SQLite.
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
    SnackBar(
      content: Text('Failed to load visitors: $e'),
    ),
  );
}

}

// Open the visitor registration form.
void _openAddVisitorForm() {
_clearControllers();

showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(20),
    ),
  ),
  builder: (ctx) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Visitor Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4434),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Visitor Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'National ID Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Phone Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship to Inmate',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _inmateController,
              decoration: const InputDecoration(
                labelText: 'Inmate Being Visited',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Visit',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _belongingsController,
              decoration: const InputDecoration(
                labelText: 'Checked Belongings / Items Left',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A1C2C),
                ),
                onPressed: () => _saveVisitor(ctx),
                child: const Text(
                  'Save Record',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  },
);

}

// Save a new visitor to SQLite.
Future<void> _saveVisitor(BuildContext sheetContext) async {
final name = _nameController.text.trim();

if (name.isEmpty) {
  ScaffoldMessenger.of(sheetContext).showSnackBar(
    const SnackBar(
      content: Text('Please enter the visitor full name.'),
    ),
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
  belongings: _belongingsController.text.trim(),
  status: 'Pending',
  visitDateTime: DateTime.now(),
);

try {
  await VisitorDatabase.instance.insertVisitor(visitor);

  if (!mounted) return;
  if (!sheetContext.mounted) return;

  Navigator.pop(sheetContext);

  _clearControllers();

  await _loadVisitors();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Visitor record saved successfully.'),
    ),
  );
} catch (e) {
  if (!sheetContext.mounted) return;

  ScaffoldMessenger.of(sheetContext).showSnackBar(
    SnackBar(
      content: Text('Could not save visitor: $e'),
    ),
  );
}

}

// Approve or reject a visitor and save the change.
Future<void> _updateVisitorStatus(
Visitor visitor,
String status,
) async {
if (visitor.id == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('This visitor has no database ID.'),
),
);
return;
}


try {
  await VisitorDatabase.instance.updateVisitorStatus(
    visitor.id!,
    status,
  );

  if (!mounted) return;

  await _loadVisitors();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Visitor status updated to $status.'),
    ),
  );
} catch (e) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Could not update visitor status: $e'),
    ),
  );
}

}

// Clear all form controllers.
void _clearControllers() {
_nameController.clear();
_idController.clear();
_phoneController.clear();
_relationshipController.clear();
_inmateController.clear();
_purposeController.clear();
_belongingsController.clear();
}

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

@override
Widget build(BuildContext context) {
// Filter visitors by search query and selected tab.
final filteredVisitors = _visitors.where((visitor) {
final query = _searchQuery.toLowerCase();

  final matchesSearch =
      visitor.name.toLowerCase().contains(query) ||
      visitor.idNumber.toLowerCase().contains(query) ||
      visitor.inmateName.toLowerCase().contains(query);

  if (_activeTab == 'Upcoming') {
    return matchesSearch && visitor.status == 'Pending';
  }

  return matchesSearch &&
      (visitor.status == 'Approved' ||
          visitor.status == 'Rejected');
}).toList();

return Scaffold(
  backgroundColor: const Color(0xFFF7F9F6),

  // Header
  appBar: AppBar(
    backgroundColor: const Color(0xFF2C4434),
    elevation: 0,
    centerTitle: true,
    title: const Text(
      'Visitor Management',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: _openAddVisitorForm,
        tooltip: 'Register visitor',
      ),
    ],
  ),

  body: Column(
    children: [
      // Tabs
      Container(
        color: const Color(0xFF2C4434),
        padding: const EdgeInsets.only(
          bottom: 12,
          left: 16,
          right: 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = 'Upcoming';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _activeTab == 'Upcoming'
                          ? const Color(0xFF7A1C2C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Upcoming Slots',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _activeTab == 'Upcoming'
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = 'History';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _activeTab == 'History'
                          ? const Color(0xFF7A1C2C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'All History Logs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _activeTab == 'History'
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Search bar
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by Visitor, ID, or Inmate...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      // Visitor records
      Expanded(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : filteredVisitors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_ind_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No visitor records added yet.'
                              : 'No matches found.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: filteredVisitors.length,
                    itemBuilder: (context, index) {
                      final visitor = filteredVisitors[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor:
                                        Color(0xFFE8F5E9),
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFF2C4434),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          visitor.name,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          'Inmate: ${visitor.inmateName} '
                                          '(${visitor.relationship})',
                                          style: TextStyle(
                                            color:
                                                Colors.grey.shade700,
                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          'Status: ${visitor.status}',
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            fontSize: 13,
                                            color: visitor.status ==
                                                    'Approved'
                                                ? Colors.teal
                                                : visitor.status ==
                                                        'Pending'
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              Text(
                                'National ID: ${visitor.idNumber}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Phone: ${visitor.phone}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Purpose: ${visitor.purpose}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Belongings: ${visitor.belongings}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Visit recorded: '
                                '${visitor.visitDateTime.toLocal()}'
                                    .split('.')
                                    .first,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              // Approve and reject actions
                              if (visitor.status == 'Pending') ...[
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style:
                                          OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Colors.red.shade700,
                                        side: BorderSide(
                                          color:
                                              Colors.red.shade300,
                                        ),
                                      ),
                                      onPressed: () =>
                                          _updateVisitorStatus(
                                        visitor,
                                        'Rejected',
                                      ),
                                      child: const Text('Reject'),
                                    ),

                                    const SizedBox(width: 12),

                                    ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2C4434),
                                      ),
                                      onPressed: () =>
                                          _updateVisitorStatus(
                                        visitor,
                                        'Approved',
                                      ),
                                      child: const Text(
                                        'Approve Entry',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    ],
  ),

  // Bottom navigation
  bottomNavigationBar: BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF2C4434),
    unselectedItemColor: Colors.grey.shade500,
    currentIndex: 1,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        label: 'Inmates',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.description_outlined),
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

import 'package:material_ui/material_ui.dart';

import '../models/visitor.dart';
import '../services/visitor_api_service.dart';
import '../../services/inmate_service.dart';
import 'visitor_details_screen.dart';

class VisitorListScreen extends StatefulWidget {
  final bool readOnly;
  const VisitorListScreen({super.key, this.readOnly = false});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  List<Visitor> _visitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    try {
      final records = await VisitorApiService.getVisits();
      final visitors = records.map(Visitor.fromApiJson).toList();

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

  Future<void> _openAddVisitorForm() async {
    final shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddVisitorScreen(),
      ),
    );

    if (!mounted) return;

    if (shouldRefresh == true) {
      await _loadVisitors();
    }
  }

  void _openDetailsWindow(
    BuildContext context,
    Visitor visitor,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => VisitorDetailsScreen(
        visitor: visitor,
      ),
    );
  }

  // Return to the Home dashboard.
  void _goToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // Open the Inmates screen.
  void _openInmates() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/inmates',
      (route) => route.isFirst,
    );
  }

  // Handle the bottom navigation buttons.
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        _goToDashboard();
        break;

      case 1:
        _openInmates();
        break;

      case 2:
        Navigator.pushNamed(context, '/tracking');
        break;

      case 3:
        _goToDashboard();
        break;
    }
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        // Back arrow returns to Home.
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: _goToDashboard,
        ),

        actions: [
          if (!widget.readOnly)
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 26,
            ),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _visitors.isEmpty
              ? const Center(
                  child: Text('No visitor records found.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = _visitors[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDetailsWindow(
                          context,
                          visitor,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8EFEA),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF344B3B),
                            ),
                          ),
                          title: Text(
                            visitor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(visitor.relationship),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6EE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              visitor.status,
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
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
      bottomNavigationBar: widget.readOnly ? null : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 11,
          color: Colors.grey,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _handleNavigation,
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
            icon: Icon(Icons.gps_fixed, color: Colors.grey),
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
  final _inmateController = TextEditingController();
  final _belongingsController = TextEditingController();
  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  bool _hasBelongings = false;
  bool _isSaving = false;
  bool _loadingInmates = true;
  List<Map<String, dynamic>> _inmates = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = _date(now);
    _startController.text = _time(now);
    _endController.text = _time(now.add(const Duration(minutes: 30)));
    _loadInmates();
  }

  Future<void> _loadInmates() async {
    try {
      final inmates = await InmateApiService.getInmates();
      if (!mounted) return;
      setState(() {
        _inmates = inmates;
        _loadingInmates = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingInmates = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load inmate choices: $error')),
      );
    }
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    _inmateController.dispose();
    _belongingsController.dispose();
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _saveVisitor() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the visitor full name.'),
        ),
      );
      return;
    }

    final inmateId = _inmateController.text.trim();
    if (inmateId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the inmate API ID (UUID).')),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);
      await VisitorApiService.recordFamilyVisit(
        visitorFullName: name,
        inmateId: inmateId,
        visitDate: _dateController.text.trim(),
        startTime: _startController.text.trim(),
        endTime: _endController.text.trim(),
        itemsBrought: _hasBelongings ? _belongingsController.text.trim() : '',
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not record visit: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Record Visitor Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
            _loadingInmates
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue: _inmateController.text.isEmpty
                        ? null
                        : _inmateController.text,
                    decoration: const InputDecoration(
                      labelText: 'Inmate being visited',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _inmates.map((inmate) {
                      final id = inmate['id']?.toString() ?? '';
                      final name = '${inmate['firstName'] ?? ''} ${inmate['lastName'] ?? ''}'.trim();
                      return DropdownMenuItem(value: id, child: Text(name.isEmpty ? id : name));
                    }).toList(),
                    onChanged: (value) => _inmateController.text = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Select an inmate'
                        : null,
                  ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Visit date (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _startController, decoration: const InputDecoration(labelText: 'Start (HH:MM)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _endController, decoration: const InputDecoration(labelText: 'End (HH:MM)'))),
            ]),
            const SizedBox(height: 16),
            const Text(
              'Are there any Checked Belongings / Items Left?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344B3B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _hasBelongings
                          ? const Color(0xFF344B3B)
                          : Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF344B3B),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _hasBelongings = true);
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: _hasBelongings
                            ? Colors.white
                            : const Color(0xFF344B3B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_hasBelongings
                          ? const Color(0xFF344B3B)
                          : Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF344B3B),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _hasBelongings = false);
                    },
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: !_hasBelongings
                            ? Colors.white
                            : const Color(0xFF344B3B),
                      ),
                    ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSaving ? null : _saveVisitor,
                child: Text(
                  _isSaving ? 'Recording...' : 'Record Visit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

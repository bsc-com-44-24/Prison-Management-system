import 'package:material_ui/material_ui.dart';

class RehabilitationScreen extends StatefulWidget {
  const RehabilitationScreen({super.key});

  @override
  State<RehabilitationScreen> createState() => _RehabilitationScreenState();
}

class _RehabilitationScreenState extends State<RehabilitationScreen> {
  int _selectedTab = 0; // 0 for Programs, 1 for Attendance

  // Predefined core rehabilitation programs shared across both tabs
  var predefinedPrograms = [
    {
      'title': 'Vocational Training',
      'category': 'Carpentry, Tailoring, Metalwork',
      'icon': Icons.handyman_outlined,
      'assignedInmateIds': <String>[],
    },
    {
      'title': 'Counselling & Psycho-Social',
      'category': 'Substance abuse & anger management',
      'icon': Icons.chat_bubble_outline,
      'assignedInmateIds': <String>[],
    },
    {
      'title': 'Education & Literacy',
      'category': 'Primary, secondary & adult literacy',
      'icon': Icons.school_outlined,
      'assignedInmateIds': <String>[],
    },
    {
      'title': 'Life Skills & Civic Education',
      'category': 'Financial literacy & reintegration prep',
      'icon': Icons.lightbulb_outline,
      'assignedInmateIds': <String>[],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      body: Column(
        children: [
          // 1. Dark Green Header
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            color: const Color(0xFF344B3B),
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
                          color:
                              _selectedTab == 0 ? Colors.white : Colors.black87,
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
                          color:
                              _selectedTab == 1 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'You are on the main Rehabilitation dashboard.')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rehabilitation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Burgundy & Grey Segmented Tab Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFF7A1F2D)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFF7A1F2D)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
          ),

          // 3. Main Content View
          Expanded(
            child:
                _selectedTab == 0 ? _buildProgramsTab() : _buildAttendanceTab(),
          ),
        ],
      ),
      // 4. Mobile Bottom Footer Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFooterItem(Icons.home_outlined, 'Home', false),
            _buildFooterItem(Icons.people_outline, 'Inmates', false),
            _buildFooterItem(Icons.assignment_outlined, 'Rehabilitation', true),
            _buildFooterItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF7A1F2D) : Colors.grey,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? const Color(0xFF7A1F2D) : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- PROGRAMS TAB ---
  Widget _buildProgramsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: predefinedPrograms.length,
      itemBuilder: (context, index) {
        final prog = predefinedPrograms[index];
        final title = prog['title'] as String;
        final category = prog['category'] as String;
        final icon = prog['icon'] as IconData;
        final assignedList = prog['assignedInmateIds'] as List;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF344B3B).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF344B3B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF344B3B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assignedList.length} participants',
                        style: const TextStyle(
                          color: Color(0xFF344B3B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Plus Button to open manual entry modal
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF7A1F2D),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _showManualAddInmateModal(prog),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- ATTENDANCE TAB ---
  Widget _buildAttendanceTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: predefinedPrograms.length,
      itemBuilder: (context, index) {
        final prog = predefinedPrograms[index];
        final title = prog['title'] as String;
        final assignedList = prog['assignedInmateIds'] as List;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1F2D).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fact_check_outlined,
                    color: Color(0xFF7A1F2D)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Inmates: ${assignedList.length}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MANUAL ENTRY MODAL WITH DUPLICATE REJECTION ---
  void _showManualAddInmateModal(Map<String, dynamic> program) {
    final TextEditingController inmateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enroll Inmate in ${program['title']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF344B3B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the inmate name or ID manually to enroll:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: inmateController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Inmate Name / ID',
                  hintText: 'e.g., John Doe (INM-109)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF7A1F2D), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F2D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final inmateName = inmateController.text.trim();
                    if (inmateName.isEmpty) return;

                    final List assignedList =
                        program['assignedInmateIds'] as List;

                    // Duplicate check & Rejection logic
                    if (assignedList.contains(inmateName)) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '❌ "$inmateName" is already enrolled in ${program['title']}!'),
                          backgroundColor: const Color(0xFF7A1F2D),
                        ),
                      );
                    } else {
                      setState(() {
                        assignedList.add(inmateName);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '✅ Successfully added "$inmateName" to ${program['title']}!'),
                          backgroundColor: const Color(0xFF344B3B),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Confirm Enrollment',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

import 'package:material_ui/material_ui.dart';

class RehabilitationScreen extends StatefulWidget {
  const RehabilitationScreen({super.key});

  @override
  State<RehabilitationScreen> createState() => _RehabilitationScreenState();
}

class _RehabilitationScreenState extends State<RehabilitationScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> predefinedPrograms = [
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
      'category': 'Financial literacy & reintegration preparation',
      'icon': Icons.lightbulb_outline,
      'assignedInmateIds': <String>[],
    },
  ];

  void _addInmate(Map<String, dynamic> program) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Inmate Name / ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F2D),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final inmate = controller.text.trim();
                    if (inmate.isEmpty) return;

                    final assigned =
                        program['assignedInmateIds'] as List<String>;
                    Navigator.pop(sheetContext);
                    if (assigned.contains(inmate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$inmate is already enrolled in this program.'),
                        ),
                      );
                      return;
                    }

                    setState(() => assigned.add(inmate));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $inmate to ${program['title']}'),
                      ),
                    );
                  },
                  child: const Text('Confirm Enrollment'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        title: const Text(
          'Rehabilitation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Programs',
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Attendance',
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: predefinedPrograms.length,
                    itemBuilder: (context, index) {
                      final program = predefinedPrograms[index];
                      final assigned =
                          program['assignedInmateIds'] as List<String>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            program['icon'] as IconData,
                            color: const Color(0xFF344B3B),
                          ),
                          title: Text(program['title'] as String),
                          subtitle: Text(
                            '${program['category']} - ${assigned.length} participants',
                          ),
                          trailing: IconButton(
                            onPressed: () => _addInmate(program),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: predefinedPrograms.length,
                    itemBuilder: (context, index) {
                      final program = predefinedPrograms[index];
                      final assigned =
                          program['assignedInmateIds'] as List<String>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.fact_check_outlined,
                            color: Color(0xFF7A1F2D),
                          ),
                          title: Text(program['title'] as String),
                          subtitle: Text(
                            'Total Inmates: ${assigned.length}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7A1F2D) : const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

class AssignInmateScreen extends StatefulWidget {
  final String programTitle;
  final List currentAssignedIds;

  const AssignInmateScreen({
    super.key,
    required this.programTitle,
    required this.currentAssignedIds,
  });

  @override
  State<AssignInmateScreen> createState() => _AssignInmateScreenState();
}

class _AssignInmateScreenState extends State<AssignInmateScreen> {
  late List assignedList;

  @override
  void initState() {
    super.initState();
    assignedList = List.from(widget.currentAssignedIds);
  }

  @override
  Widget build(BuildContext context) {
    final Box? inmatesBox =
        Hive.isBoxOpen('inmates_box') ? Hive.box('inmates_box') : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        title: Text(
          'Assign to ${widget.programTitle}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: inmatesBox == null || inmatesBox.isEmpty
          ? const Center(
              child: Text(
                'No inmates found in database (inmates_box).',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inmatesBox.length,
              itemBuilder: (context, index) {
                final inmate = inmatesBox.getAt(index);
                final name = inmate is Map
                    ? (inmate['name'] ??
                            inmate['fullName'] ??
                            'Inmate ${index + 1}')
                        .toString()
                    : 'Inmate ${index + 1}';
                final inmateId =
                    inmate is Map ? (inmate['id'] ?? name).toString() : name;
                final isAlreadyAssigned = assignedList.contains(inmateId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF344B3B),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(name),
                    subtitle: Text('ID: $inmateId'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyAssigned
                            ? Colors.grey
                            : const Color(0xFF7A1F2D),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (isAlreadyAssigned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$name is already enrolled in ${widget.programTitle}.',
                              ),
                              backgroundColor: const Color(0xFF7A1F2D),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          assignedList.add(inmateId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully added $name to ${widget.programTitle}.',
                            ),
                          ),
                        );
                      },
                      child: Text(isAlreadyAssigned ? 'Enrolled' : 'Assign'),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF344B3B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => Navigator.pop(context, assignedList),
          child: const Text('Save and Return'),
        ),
      ),
    );
  }
}

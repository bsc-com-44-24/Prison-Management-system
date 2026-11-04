import 'package:flutter/material.dart';

import 'assign_inmate_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  final String programTitle;

  const ProgramDetailScreen({super.key, required this.programTitle});

  @override
  Widget build(BuildContext context) {
    // Mock assigned list for demonstration; connect this to your Hive Box later
    final List<String> assignedInmates = [
      'John Doe (Cell Block A)',
      'Michael Smith (Cell Block B)',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        title: Text(programTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Inmates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344B3B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: assignedInmates.isEmpty
                  ? const Center(
                      child: Text('No inmates assigned to this program yet.'),
                    )
                  : ListView.builder(
                      itemCount: assignedInmates.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF7A1F2D),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(assignedInmates[index]),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Handle removing inmate from program
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF7A1F2D,
                    ), // Burgundy action button
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).wrap(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A1F2D),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Navigate to selection screen to pick an inmate from database
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AssignInmateScreen(programTitle: programTitle),
                          ),
                        );
                      },
                      child: const Text(
                        'Assign Inmate to Program',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

extension on ButtonStyle {
  Widget wrap(Widget child) => child; // Helper wrapper for button styling
}

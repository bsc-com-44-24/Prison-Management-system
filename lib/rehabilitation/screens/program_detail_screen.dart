import 'package:flutter/material.dart';

class ProgramDetailScreen extends StatelessWidget {
  final String programTitle;
  final List assignedInmates;

  const ProgramDetailScreen({
    super.key,
    required this.programTitle,
    required this.assignedInmates,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        title: Text('$programTitle Roster',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Enrolled Participants: ${assignedInmates.length}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A1F2D)),
            ),
            const Divider(height: 24),
            Expanded(
              child: assignedInmates.isEmpty
                  ? const Center(
                      child: Text(
                        'No inmates assigned to this program yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      itemCount: assignedInmates.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF344B3B),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 16),
                            ),
                            title: Text(
                                'Inmate ID / Name: ${assignedInmates[index]}'),
                            subtitle: const Text('Status: Active Participant'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

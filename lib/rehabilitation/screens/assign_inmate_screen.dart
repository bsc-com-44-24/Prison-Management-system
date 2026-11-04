import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssignInmateScreen extends StatelessWidget {
  final String programTitle;

  const AssignInmateScreen({super.key, required this.programTitle});

  @override
  Widget build(BuildContext context) {
    // Opening your existing inmates box safely
    final inmatesBox = Hive.box('inmates_box');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF344B3B),
        title: Text(
          'Assign to $programTitle',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: inmatesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No inmates found in database. Add inmates first!'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final inmate = box.getAt(index);
              // Adjust keys based on your inmate model structure (e.g., name, cellBlock)
              final inmateName =
                  inmate['name'] ??
                  inmate['fullName'] ??
                  'Inmate #${index + 1}';
              final cellBlock = inmate['cellBlock'] ?? 'Cell Block A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    inmateName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Location: $cellBlock'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF344B3B),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Save assignment relation to your Hive database here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$inmateName assigned to $programTitle successfully!',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Assign'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

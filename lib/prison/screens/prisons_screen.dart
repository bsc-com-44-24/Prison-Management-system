import 'package:flutter/material.dart';
import 'package:prison_management_system/transfer/widgets/custom_bottom_nav.dart';

class RegisteredPrisonsScreen extends StatefulWidget {
  const RegisteredPrisonsScreen({Key? key}) : super(key: key);

  @override
  _RegisteredPrisonsScreenState createState() => _RegisteredPrisonsScreenState();
}

class _RegisteredPrisonsScreenState extends State<RegisteredPrisonsScreen> {
  int _currentIndex = 0; // Correctly reflects that the Home/Prisons tab is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2E20),
        automaticallyImplyLeading: false,
        title: const Text('Prisons'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'select the prisons to view the inmates',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchRegisteredPrisons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No registered prisons found.'));
                }

                final prisons = snapshot.data!;
                return ListView.builder(
                  itemCount: prisons.length,
                  itemBuilder: (context, index) {
                    final prison = prisons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          prison['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(prison['location'] ?? ''),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.man),
                                    const Text('Male'),
                                    Text('${prison['maleCount'] ?? 0}'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.woman),
                                    const Text('Female'),
                                    Text('${prison['femaleCount'] ?? 0}'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.grid_view),
                                    const Text('Total'),
                                    Text('${prison['totalCount'] ?? 0}'),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Add your navigation route handler here
        },
      ),
    );
  }

  Future<List<dynamic>> fetchRegisteredPrisons() async {
    // API request placeholder returning registered prisons
    return [];
  }
}

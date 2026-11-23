import 'package:flutter/material.dart';

class IncomingTransfersScreen extends StatefulWidget {
  const IncomingTransfersScreen({Key? key}) : super(key: key);

  @override
  State<IncomingTransfersScreen> createState() => _IncomingTransfersScreenState();
}

class _IncomingTransfersScreenState extends State<IncomingTransfersScreen> {
  // Completely empty list with zero mock data, ready for backend API integration
  var _incomingTransfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncomingTransfers();
  }

  Future<void> _fetchIncomingTransfers() async {
    // TODO: Replace with actual backend GET request, e.g., GET /api/v1/transfers/incoming
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _incomingTransfers = []; // Keeps the screen empty and clean
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2E20),
        title: const Text('Incoming Transfers'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Verify physical arrival or report transit incidents for transferred inmates',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B2E20)))
                : _incomingTransfers.isEmpty
                    ? const Center(
                        child: Text(
                          'No incoming transfers currently in transit.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _incomingTransfers.length,
                        itemBuilder: (context, index) {
                          final transfer = _incomingTransfers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        transfer['inmateName'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          transfer['status'] ?? '',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${transfer['inmateId']}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.apartment, size: 16, color: Color(0xFF7A1F2D)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'From: ${transfer['sourcePrison']}',
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.description, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Reason: ${transfer['reason']}',
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF7A1F2D),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _showConfirmationDialog(context, transfer),
                                          icon: const Icon(Icons.verified, color: Colors.white, size: 16),
                                          label: const Text('Confirm Receipt', style: TextStyle(color: Colors.white, fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF7A1F2D),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _showIncidentDialog(context, transfer),
                                          icon: const Icon(Icons.warning_amber, color: Colors.white, size: 16),
                                          label: const Text('Report Incident', style: TextStyle(color: Colors.white, fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  void _showConfirmationDialog(BuildContext context, Map<String, dynamic> transfer) {
    bool identityChecked = false;
    bool physicalChecked = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Confirm Arrival: ${transfer['inmateName']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please perform physical verification before confirming receipt into the facility roster.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Inmate ID badge & paperwork verified', style: TextStyle(fontSize: 13)),
                    value: identityChecked,
                    onChanged: (val) => setDialogState(() => identityChecked = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Physical health & intake condition checked', style: TextStyle(fontSize: 13)),
                    value: physicalChecked,
                    onChanged: (val) => setDialogState(() => physicalChecked = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F2D),
                  ),
                  onPressed: identityChecked && physicalChecked
                      ? () {
                          // TODO: Connect PUT /api/v1/transfers/{id}/confirm
                          setState(() {
                            _incomingTransfers.removeWhere((t) => t['id'] == transfer['id']);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${transfer['inmateName']} successfully added to facility roster!')),
                          );
                        }
                      : null,
                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIncidentDialog(BuildContext context, Map<String, dynamic> transfer) {
    final TextEditingController incidentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report Transit Incident: ${transfer['inmateName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Describe the transit anomaly (e.g., escape en route, medical emergency, vehicle delay):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: incidentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter incident details...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1F2D),
              ),
              onPressed: () {
                // TODO: Connect POST /api/v1/transfers/{id}/incident
                setState(() {
                  _incomingTransfers.removeWhere((t) => t['id'] == transfer['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Incident reported for ${transfer['inmateName']}. Security alert broadcasted.'),
                    backgroundColor: const Color(0xFF7A1F2D),
                  ),
                );
              },
              child: const Text('Submit Alert', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
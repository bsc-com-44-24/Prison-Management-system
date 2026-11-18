import 'package:flutter/material.dart';
import '../models/transfer_model.dart';

class TransferApprovalScreen extends StatefulWidget {
  final TransferRequestPayload? transferRequest;

  const TransferApprovalScreen({Key? key, this.transferRequest}) : super(key: key);

  @override
  _TransferApprovalScreenState createState() => _TransferApprovalScreenState();
}

class _TransferApprovalScreenState extends State<TransferApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final request = widget.transferRequest;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2E20),
        automaticallyImplyLeading: true,
        title: const Text('Approve Transfer'),
        centerTitle: true,
      ),
      body: request == null
          ? const Center(
              child: Text(
                'No transfer request data available.\nWaiting for backend payload...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review transfer request and take action',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Transfer Request Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF7A1F2D),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.description, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Transfer Request Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow('Inmate Name:', request.inmateName),
                              const Divider(height: 16),
                              _buildDetailRow('Inmate ID:', request.inmateId),
                              const Divider(height: 16),
                              _buildDetailRow('Current Prison:', request.sourcePrisonName),
                              const Divider(height: 16),
                              _buildDetailRow('Destination Prison:', request.destinationPrisonName),
                              const Divider(height: 16),
                              _buildDetailRow('Reason:', request.reason),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status:',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      request.status,
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Destination Capacity Card (Dynamic placeholder ready for API integration)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info, color: Color(0xFF1B2E20), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Destination Capacity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E20),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${request.destinationPrisonName} Capacity: --', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('Current Inmates: --', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.check_box, color: Colors.green, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Destination capacity checked',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Approve & Reject)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2E20),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _approveTransfer,
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                          label: const Text('Approve', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A1F2D),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _rejectTransfer,
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          label: const Text('Reject', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _approveTransfer() {
    // TODO: Connect to backend API endpoint to approve transfer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer request approved successfully!')),
    );
    Navigator.pop(context);
  }

  void _rejectTransfer() {
    // TODO: Connect to backend API endpoint to reject transfer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer request rejected.')),
    );
    Navigator.pop(context);
  }
}
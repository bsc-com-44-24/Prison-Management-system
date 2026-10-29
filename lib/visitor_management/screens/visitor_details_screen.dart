import 'package:flutter/material.dart';
import '../models/visitor.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const VisitorDetailsScreen({
    super.key,
    required this.visitor,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.assignment_ind, color: Color(0xFF344B3B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Log Details',
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Full Name:', visitor.name),
            _buildDetailRow('National ID:', visitor.idNumber),
            _buildDetailRow('Phone Number:', visitor.phone),
            _buildDetailRow('Relationship:', visitor.relationship),
            _buildDetailRow('Visiting Inmate:', visitor.inmateName),
            _buildDetailRow('Purpose of Visit:', visitor.purpose),
            _buildDetailRow('Items/Belongings:', visitor.belongings),
            _buildDetailRow('Current Decision:', visitor.status),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDecline();
          },
          child: const Text(
            'Decline',
            style: TextStyle(color: Color(0xFF7A1F2D), fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A1F2D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onApprove();
          },
          child: const Text('Approve', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? 'Not Provided' : value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../models/visitor.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailsScreen({
    super.key,
    required this.visitor,
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
            _buildDetailRow('Relationship:', visitor.relationship),
            _buildDetailRow('Visiting Inmate:', visitor.inmateName),
            _buildDetailRow('Items/Belongings:', visitor.belongings),
            _buildDetailRow('Visit date and time:', visitor.visitDateTime.toLocal().toString()),
            _buildDetailRow('Record status:', visitor.status),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
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
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? 'Not Provided' : value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReleaseStepCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final IconData icon;
  final VoidCallback? onTap;

  const ReleaseStepCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF344B3B);

    final bool isCompleted = status == 'Completed';
    final bool isApproved = status == 'Approved';

    final Color statusColor =
        isCompleted || isApproved ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.12),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/staff_model.dart';

class RosterCard extends StatelessWidget {
  final ShiftModel shift;

  const RosterCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;

    if (shift.status == 'Active Now') {
      badgeColor = Colors.red.shade50;
      badgeTextColor = Colors.red.shade800;
    } else if (shift.status == 'High Alert') {
      badgeColor = Colors.orange.shade50;
      badgeTextColor = Colors.orange.shade800;
    } else {
      badgeColor = Colors.green.shade50;
      badgeTextColor = Colors.green.shade800;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift Header & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    shift.shiftName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    shift.timeRange,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shift.status,
                  style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          // Supervisor Details Row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2C4A3E).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF2C4A3E), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.supervisorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      shift.supervisorRole,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Contact", style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Footer: Officer Count & Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "${shift.officerCount} Officers - ${shift.assignedLocation}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
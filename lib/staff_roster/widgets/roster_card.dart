import 'package:flutter/material.dart';
import '../models/staff_model.dart';

class RosterCard extends StatelessWidget {
  final ShiftModel shift;
  final VoidCallback onContactPressed; // Callback for popup action

  const RosterCard({
    super.key, 
    required this.shift,
    required this.onContactPressed,
  });

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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2C4A3E).withValues(alpha: 0.1),
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
                onPressed: onContactPressed, // Hooks up the pop-up modal
                child: const Text("Contact", style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Wrap the inner row in Expanded so it occupies available space smoothly
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined, // or Icons.security
                      size: 15,
                      color: Color(0xFF2C2C2C), // Crisp dark grey icon
                    ),
                    const SizedBox(width: 6),
                    // 2. Wrap Text in Flexible/Expanded with TextOverflow.ellipsis
                    Expanded(
                      child: Text(
                        "${shift.officerCount} Officers - ${shift.assignedLocation}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Prevents text squishing on narrow screens
                        style: const TextStyle(
                          color: Color(0xFF2C2C2C), // Solid high-contrast color
                          fontSize: 12,
                          fontWeight: FontWeight.w600, // Semi-bold for extra clarity on low-DPI displays
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF666666),
              ),
            ],
          )
        ],
      ),
    );
  }
}
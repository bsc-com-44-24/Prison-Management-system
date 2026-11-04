import 'package:flutter/material.dart';

class ReleaseBottomNav extends StatelessWidget {
  const ReleaseBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    const grey = Color(0xFF9AA3B2);

    Widget item(IconData icon, String label) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              item(Icons.home_outlined, 'Home'),
              item(Icons.groups_outlined, 'Inmates'),
              item(Icons.location_on_outlined, 'Tracking'),
              item(Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
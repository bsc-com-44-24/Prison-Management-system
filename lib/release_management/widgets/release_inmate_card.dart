import 'package:flutter/material.dart';
import '../../Inmate_management/models/inmate_model.dart';

class ReleaseInmateCard extends StatelessWidget {
  final InmateModel inmate;
  final VoidCallback onTap;
  final String status;

  const ReleaseInmateCard({
    super.key,
    required this.inmate,
    required this.onTap,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF344B3B);
    const burgundy = Color(0xFF801F32);

    final releaseDate = DateTime.tryParse(inmate.releaseDate);
    final today = DateTime.now();

    final daysRemaining = releaseDate == null
        ? null
        : DateTime(
                releaseDate.year,
                releaseDate.month,
                releaseDate.day,
              )
              .difference(DateTime(today.year, today.month, today.day))
              .inDays;

    String countdown = 'Date unavailable';
    Color countdownColor = Colors.grey;

    if (daysRemaining != null) {
      if (daysRemaining <= 7) {
        countdown = daysRemaining < 0
            ? 'Date passed'
            : 'Due Soon';
        countdownColor = burgundy;
      } else {
        countdown = 'In $daysRemaining days';
        countdownColor = const Color(0xFF648267);
      }
    }

    if (status == 'Released') {
      countdown = 'Released';
      countdownColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFFE5EBE6),
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inmate.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${inmate.id} · ${inmate.offenceCategory}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Release: ${inmate.releaseDate}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: countdownColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  countdown,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
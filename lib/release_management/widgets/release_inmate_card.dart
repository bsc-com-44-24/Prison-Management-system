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

return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.12),
            child: const Icon(
              Icons.person,
              color: primaryColor,
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
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text('Prison No: ${inmate.id}'),
                Text('Offence: ${inmate.offenceCategory}'),
                Text('Release Date: ${inmate.releaseDate}'),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Released'
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Released'
                          ? Colors.green.shade800
                          : Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  ),
);
}
}

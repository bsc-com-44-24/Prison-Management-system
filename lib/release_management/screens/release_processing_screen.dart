import 'package:flutter/material.dart';

import '../../Inmate_management/models/inmate_model.dart';
import '../services/release_database.dart';
import '../widgets/release_step_card.dart';

class ReleaseProcessingScreen extends StatefulWidget {
  final InmateModel inmate;
  final Map<String, Object?> release;

  const ReleaseProcessingScreen({
    super.key,
    required this.inmate,
    required this.release,
  });

  @override
  State<ReleaseProcessingScreen> createState() =>
      _ReleaseProcessingScreenState();
}

class _ReleaseProcessingScreenState
    extends State<ReleaseProcessingScreen> {
  static const Color primaryColor = Color(0xFF344B3B);

  late Map<String, Object?> release;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    release = Map<String, Object?>.from(widget.release);
  }

  Future<void> updateReleaseStage({
    required String column,
    required String newStatus,
    required String title,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $title'),
        content: Text('Are you sure you want to update $title?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isUpdating = true);

    try {
      final releaseId = release['id'] as int;

      await ReleaseDatabase.instance.updateStage(
        releaseId: releaseId,
        column: column,
        status: newStatus,
      );

      final records =
          await ReleaseDatabase.instance.getAllReleases();

      final updatedRecord = records.firstWhere(
        (record) => record['id'] == releaseId,
      );

      if (!mounted) return;

      setState(() {
        release = updatedRecord;
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update $title: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verification = release['verification_status'] as String;
    final clearance = release['clearance_status'] as String;
    final approval = release['approval_status'] as String;
    final releaseStatus = release['release_status'] as String;

    final steps = [
      {
        'title': 'Verify Inmate Details',
        'description':
            'Confirm the inmate identity and verify their personal and sentence details.',
        'status': verification,
        'column': 'verification_status',
        'newStatus': 'Completed',
        'icon': Icons.verified_user,
        'enabled': verification == 'Pending',
      },
      {
        'title': 'Clearance Checks',
        'description':
            'Confirm that all required clearance checks have been completed.',
        'status': clearance,
        'column': 'clearance_status',
        'newStatus': 'Completed',
        'icon': Icons.fact_check,
        'enabled': verification == 'Completed' &&
            clearance == 'Pending',
      },
      {
        'title': 'Approval',
        'description':
            'Record the required authorization for the inmate’s release.',
        'status': approval,
        'column': 'approval_status',
        'newStatus': 'Approved',
        'icon': Icons.approval,
        'enabled': clearance == 'Completed' &&
            approval == 'Pending',
      },
      {
        'title': 'Release',
        'description':
            'Complete the release process after all previous stages have been approved.',
        'status': releaseStatus,
        'column': 'release_status',
        'newStatus': 'Released',
        'icon': Icons.door_front_door,
        'enabled': approval == 'Approved' &&
            releaseStatus != 'Released',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Release Processing'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inmate Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Name: ${widget.inmate.fullName}'),
                          Text('Prison Number: ${widget.inmate.id}'),
                          Text(
                            'Offence: ${widget.inmate.offenceCategory}',
                          ),
                          Text(
                            'Release Date: ${widget.inmate.releaseDate}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Release Process',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete each stage in order. The next stage '
                    'becomes available after the previous stage is completed.',
                  ),
                  const SizedBox(height: 12),
                  ...steps.map((step) {
                    final status = step['status'] as String;
                    final enabled = step['enabled'] as bool;
                    final isFinished =
                        status == 'Completed' ||
                        status == 'Approved' ||
                        status == 'Released';

                    return Column(
                      children: [
                        ReleaseStepCard(
                          title: step['title'] as String,
                          description:
                              step['description'] as String,
                          status: status,
                          icon: step['icon'] as IconData,
                          onTap: enabled
                              ? () {
                                  updateReleaseStage(
                                    column:
                                        step['column'] as String,
                                    newStatus:
                                        step['newStatus'] as String,
                                    title: step['title'] as String,
                                  );
                                }
                              : null,
                        ),
                        if (enabled)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                updateReleaseStage(
                                  column: step['column'] as String,
                                  newStatus:
                                      step['newStatus'] as String,
                                  title: step['title'] as String,
                                );
                              },
                              icon: const Icon(Icons.check_circle),
                              label: Text(
                                'Complete ${step['title']}',
                              ),
                            ),
                          ),
                        if (isFinished)
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Stage completed',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
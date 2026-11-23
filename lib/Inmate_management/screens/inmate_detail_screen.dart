import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../models/inmate_model.dart';
import '../../services/inmate_service.dart';
import 'new_inmate_screen.dart';

class InmateDetailScreen extends StatefulWidget {
  final InmateModel inmate;
  final String currentUserRole;

  const InmateDetailScreen({
    super.key,
    required this.inmate,
    this.currentUserRole = 'Records Officer',
  });

  @override
  State<InmateDetailScreen> createState() => _InmateDetailScreenState();
}

class _InmateDetailScreenState extends State<InmateDetailScreen> {
  late InmateModel _currentInmate;
  List<InmateModel> _priorRecords = [];

  @override
  void initState() {
    super.initState();
    _currentInmate = widget.inmate;
    _loadPriorRecords();
  }

  Future<void> _loadPriorRecords() async {
    try {
      final records = await InmateApiService.getInmates(
        search: _currentInmate.fullName,
      );
      if (!mounted) return;
      setState(() {
        _priorRecords = records
            .map(InmateModel.fromApiJson)
            .where(
              (record) =>
                  record.id != _currentInmate.id &&
                  record.fullName.toLowerCase().trim() ==
                      _currentInmate.fullName.toLowerCase().trim() &&
                  record.dateOfBirth.trim() ==
                      _currentInmate.dateOfBirth.trim(),
            )
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load prior admissions: $error')),
      );
    }
  }

  void _openFullImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsReleased() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Release'),
        content: Text(
          'Mark ${_currentInmate.fullName} (${_currentInmate.id}) as Released? Their record will remain stored in the centralized system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF344b3b),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Release'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await InmateApiService.dischargeInmate(_currentInmate.id);
      if (!mounted) return;
      final today = DateTime.now();
      final actualReleaseDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';
      setState(() {
        _currentInmate = InmateModel(
          id: _currentInmate.id,
          fullName: _currentInmate.fullName,
          gender: _currentInmate.gender,
          age: _currentInmate.age,
          dateOfBirth: _currentInmate.dateOfBirth,
          admissionDate: _currentInmate.admissionDate,
          inmateType: _currentInmate.inmateType,
          nationality: _currentInmate.nationality,
          facility: _currentInmate.facility,
          cellId: _currentInmate.cellId,
          offenceCategory: _currentInmate.offenceCategory,
          sentenceYears: _currentInmate.sentenceYears,
          releaseDate: actualReleaseDate,
          status: 'Released',
          photos: _currentInmate.photos,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF344b3b),
          content: Text('${_currentInmate.fullName} discharged.'),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not discharge inmate: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _currentInmate.status == 'Active';
    final normalizedRole = widget.currentUserRole.toLowerCase().trim();
    final bool isRecordOfficer = normalizedRole == 'record officer' ||
        normalizedRole == 'records officer' ||
        normalizedRole == 'admin' ||
        normalizedRole == 'super admin' ||
        normalizedRole == 'system admin' ||
        normalizedRole == 'system administrator';
    final bool isPrisonOfficer =
        normalizedRole == 'prison officer' ||
        normalizedRole == 'duty officer' ||
        normalizedRole == 'admin' ||
        normalizedRole == 'super admin' ||
        normalizedRole == 'system admin' ||
        normalizedRole == 'system administrator';
    final bool hasPhotos = _currentInmate.photos.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF344b3b),
        title: const Text(
          'Inmate Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Header Profile Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: hasPhotos
                        ? () => _openFullImage(_currentInmate.photos.first)
                        : null,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: hasPhotos
                          ? MemoryImage(_currentInmate.photos.first)
                          : null,
                      child: !hasPhotos
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentInmate.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentInmate.id,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentInmate.status,
                      style: TextStyle(
                        color: isActive ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Captured Inmate Photos Gallery (Tap any photo to open full-screen)
            if (hasPhotos) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Captured Photos (${_currentInmate.photos.length}/3) — Tap to view',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _currentInmate.photos.map((photoBytes) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _openFullImage(photoBytes),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              height: 95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                image: DecorationImage(
                                  image: MemoryImage(photoBytes),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // 3. Prior Admission / Recidivism Alert Card
            if (_priorRecords.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Prior Records Found (${_priorRecords.length})',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._priorRecords.map(
                      (prev) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${prev.id} | ${prev.facility} | ${prev.offenceCategory} (${prev.status})',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 4. Main Details Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Full Name', _currentInmate.fullName),
                  _buildDetailRow('Gender', _currentInmate.gender),
                  _buildDetailRow('Age', '${_currentInmate.age} years'),
                  _buildDetailRow('Date of Birth', _currentInmate.dateOfBirth),
                  _buildDetailRow('Nationality', _currentInmate.nationality),
                  _buildDetailRow('Prison', _currentInmate.facility),
                  _buildDetailRow('Offence', _currentInmate.offenceCategory),
                  _buildDetailRow(
                    'Sentence',
                    '${_currentInmate.sentenceYears} years',
                  ),
                  _buildDetailRow(
                    isActive ? 'Expected Release' : 'Released On',
                    _currentInmate.releaseDate,
                    isHighlight: true,
                  ),
                  _buildDetailRow(
                    'Cell',
                    _currentInmate.cellId.isEmpty
                        ? 'Not assigned'
                        : _currentInmate.cellId,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Role-Restricted Action Buttons
            if (isRecordOfficer) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7a1f2d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewInmateScreen(inmateToEdit: _currentInmate),
                      ),
                    );
                    if (updated == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            if (isPrisonOfficer && isActive) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF344b3b),
                    side: const BorderSide(
                      color: Color(0xFF344b3b),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _markAsReleased,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text(
                    'Complete Discharge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? const Color(0xFF7a1f2d) : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

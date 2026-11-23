import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../models/inmate_model.dart';
import '../../services/inmate_service.dart';

class NewInmateScreen extends StatefulWidget {
  final InmateModel? inmateToEdit;

  const NewInmateScreen({super.key, this.inmateToEdit});

  @override
  State<NewInmateScreen> createState() => _NewInmateScreenState();
}

class _NewInmateScreenState extends State<NewInmateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();
  final TextEditingController nextOfKinNameController = TextEditingController();
  final TextEditingController nextOfKinRelationshipController =
      TextEditingController();
  final TextEditingController nextOfKinPhoneController =
      TextEditingController();
  final TextEditingController nextOfKinEmailController =
      TextEditingController();
  final TextEditingController expectedCourtDateController =
      TextEditingController();
  final TextEditingController homeOfOriginController = TextEditingController();
  final TextEditingController offenceController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  String? selectedGender;
  String selectedInmateType = 'REMAND';
  String selectedSentenceType = 'FIXED_TERM';
  String? selectedCellId;
  List<Map<String, dynamic>> _cells = [];
  List<Map<String, dynamic>> _prisons = [];
  bool _isLoadingCells = true;
  bool _isSaving = false;
  String? _cellError;
  final List<Uint8List> _capturedPhotos = [];
  final List<String> genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    admissionDateController.text = _formatDate(DateTime.now());
    if (widget.inmateToEdit != null) {
      final inmate = widget.inmateToEdit!;
      nameController.text = inmate.fullName;
      idController.text = inmate.id;
      dobController.text = inmate.dateOfBirth;
      admissionDateController.text = inmate.admissionDate.isEmpty
          ? _formatDate(DateTime.now())
          : inmate.admissionDate;
      selectedInmateType = inmate.inmateType;
      offenceController.text = inmate.offenceCategory;
      sentenceController.text = inmate.sentenceYears.toString();
      selectedCellId = inmate.cellId.isEmpty ? null : inmate.cellId;
      selectedGender = inmate.gender;
      _capturedPhotos.addAll(inmate.photos);
    }
    _loadCells();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _loadCells() async {
    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        InmateApiService.getCells(),
        ApiClient.instance.getAllPages('/prisons'),
      ]);
      if (!mounted) return;
      setState(() {
        _cells = results[0];
        _prisons = results[1];
        _isLoadingCells = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _cellError = error.message;
        _isLoadingCells = false;
      });
    }
  }

  String _cellLabel(Map<String, dynamic> cell) {
    final prisonId = cell['prisonId']?.toString();
    final prison = _prisons.where((item) => item['id']?.toString() == prisonId);
    final prisonName = prison.isEmpty
        ? (prisonId ?? 'Prison')
        : prison.first['name']?.toString() ?? 'Prison';
    final cellName = cell['name']?.toString() ??
        'Cell ${cell['cellNumber']?.toString() ?? ''}'.trim();
    return '$prisonName • ${cell['blockName'] ?? 'Block'} • $cellName';
  }

  String? _validateDate(String? value) {
    if (value == null || DateTime.tryParse(value.trim()) == null) {
      return 'Enter a valid date in yyyy-mm-dd format';
    }
    return null;
  }

  String? _validateOptionalDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _validateDate(value);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool requiredField = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator ??
            (value) => requiredField && (value == null || value.trim().isEmpty)
                ? '$label is required'
                : null,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    dobController.dispose();
    admissionDateController.dispose();
    bioController.dispose();
    medicalHistoryController.dispose();
    nextOfKinNameController.dispose();
    nextOfKinRelationshipController.dispose();
    nextOfKinPhoneController.dispose();
    nextOfKinEmailController.dispose();
    expectedCourtDateController.dispose();
    homeOfOriginController.dispose();
    offenceController.dispose();
    sentenceController.dispose();
    super.dispose();
  }

  // Opens the live camera viewfinder dialog (defaults to rear camera on mobile)
  Future<void> _captureInmatePhoto() async {
    if (_capturedPhotos.isNotEmpty) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF7a1f2d),
            content: Text('No camera found on this device.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      final Uint8List? capturedBytes = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CameraCaptureDialog(cameras: cameras),
      );

      if (capturedBytes != null && mounted) {
        setState(() {
          _capturedPhotos.add(capturedBytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7a1f2d),
          content: Text('Camera error: $e'),
        ),
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

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.inmateToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF344b3b),
        title: Text(
          isEditing ? 'Edit Inmate' : 'New Inmate',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditing) ...[
                // The backend accepts one inmate photo per record.
                const Text(
                  'Inmate Photo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF344b3b),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _capturedPhotos.isEmpty
                              ? _captureInmatePhoto
                              : null,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            _capturedPhotos.isEmpty
                                ? 'Capture inmate photo'
                                : 'Photo captured',
                          ),
                        ),
                      ),
                      if (_capturedPhotos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children:
                              _capturedPhotos.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _openFullImage(entry.value),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      image: DecorationImage(
                                        image: MemoryImage(entry.value),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  top: -6,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _capturedPhotos.removeAt(entry.key),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xFF7a1f2d),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Full Name
              const Text(
                'Full Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  final parts = (val ?? '')
                      .trim()
                      .split(RegExp(r'\s+'))
                      .where((part) => part.isNotEmpty)
                      .toList();
                  return parts.length < 2
                      ? 'Enter the inmate’s first and last name'
                      : null;
                },
              ),
              const SizedBox(height: 16),

              if (isEditing) ...[
                const Text(
                  'Inmate ID',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: idController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ] else
                const Text(
                  'The API will assign the inmate ID after registration.',
                  style: TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 16),

              const Text(
                'Allocate Cell',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_isLoadingCells)
                const LinearProgressIndicator()
              else if (_cellError != null)
                Row(
                  children: [
                    Expanded(child: Text(_cellError!)),
                    IconButton(
                      onPressed: _loadCells,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedCellId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: const Text('Select an available cell'),
                  items: _cells.map((cell) {
                    final id = cell['id']?.toString() ?? '';
                    return DropdownMenuItem(
                      value: id,
                      child: Text(_cellLabel(cell)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCellId = value),
                  validator: (value) =>
                      value == null ? 'Please select a cell' : null,
                ),
              const SizedBox(height: 16),

              // 5. Gender
              const Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text('Select Gender'),
                items: genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                validator: (val) => val == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 16),

              // 6. Date of Birth
              const Text(
                'Date of Birth',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(
                  hintText: 'yyyy-mm-dd',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: _validateDate,
              ),
              const SizedBox(height: 16),

              const Text(
                'Admission Date',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: admissionDateController,
                decoration: InputDecoration(
                  hintText: 'yyyy-mm-dd',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: _validateDate,
              ),
              const SizedBox(height: 16),

              if (!isEditing) ...[
                const Text(
                  'Inmate Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedInmateType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'REMAND', child: Text('Remand')),
                    DropdownMenuItem(
                      value: 'SENTENCED',
                      child: Text('Sentenced'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedInmateType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Bio',
                  controller: bioController,
                  requiredField: true,
                  maxLines: 3,
                ),
                _buildTextField(
                  label: 'Medical History',
                  controller: medicalHistoryController,
                  requiredField: true,
                  maxLines: 3,
                ),
                _buildTextField(
                  label: 'Next of Kin Name',
                  controller: nextOfKinNameController,
                ),
                _buildTextField(
                  label: 'Next of Kin Relationship',
                  controller: nextOfKinRelationshipController,
                ),
                _buildTextField(
                  label: 'Next of Kin Phone',
                  controller: nextOfKinPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  label: 'Next of Kin Email (optional)',
                  controller: nextOfKinEmailController,
                  requiredField: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  label: 'Home of Origin (optional)',
                  controller: homeOfOriginController,
                  requiredField: false,
                ),
                if (selectedInmateType == 'REMAND')
                  _buildTextField(
                    label: 'Expected Court Date (optional)',
                    controller: expectedCourtDateController,
                    requiredField: false,
                    hint: 'yyyy-mm-dd',
                    validator: _validateOptionalDate,
                  ),
              ],

              if (!isEditing && selectedInmateType == 'SENTENCED') ...[
                const Text(
                  'Offence',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: offenceController,
                  decoration: InputDecoration(
                    hintText: 'Enter offence',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => selectedInmateType == 'SENTENCED' &&
                          (val == null || val.trim().isEmpty)
                      ? 'Please enter an offence'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sentence Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSentenceType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'FIXED_TERM',
                      child: Text('Fixed Term'),
                    ),
                    DropdownMenuItem(value: 'LIFE', child: Text('Life')),
                    DropdownMenuItem(
                      value: 'UNDETERMINED',
                      child: Text('Undetermined'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedSentenceType = value);
                    }
                  },
                ),
                if (selectedSentenceType == 'FIXED_TERM') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Sentence (years)',
                    controller: sentenceController,
                    keyboardType: TextInputType.number,
                    hint: 'e.g. 5',
                    validator: (value) {
                      final years = int.tryParse(value?.trim() ?? '');
                      return years == null || years <= 0
                          ? 'Enter a positive number of years'
                          : null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 32),

              // Save Button
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
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate() ||
                              selectedCellId == null ||
                              _isLoadingCells ||
                              _cellError != null) {
                            return;
                          }

                          setState(() => _isSaving = true);
                          final nameParts =
                              nameController.text.trim().split(RegExp(r'\s+'));
                          final firstName = nameParts.first;
                          final lastName = nameParts.skip(1).join(' ');
                          final admissionDate =
                              admissionDateController.text.trim();
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            if (isEditing) {
                              final inmateId = widget.inmateToEdit!.id;
                              await InmateApiService.updateInmate(
                                id: inmateId,
                                inmate: {
                                  'firstName': firstName,
                                  'lastName': lastName,
                                  'dateOfBirth': dobController.text.trim(),
                                  'gender': selectedGender,
                                  'admissionDate': admissionDate,
                                },
                              );
                              if (selectedCellId !=
                                  widget.inmateToEdit!.cellId) {
                                await InmateApiService.allocateCell(
                                  inmateId: inmateId,
                                  cellId: selectedCellId!,
                                );
                              }
                            } else {
                              final inmate = <String, dynamic>{
                                'firstName': firstName,
                                'lastName': lastName,
                                'dateOfBirth': dobController.text.trim(),
                                'gender': selectedGender,
                                'admissionDate': admissionDate,
                                'inmateType': selectedInmateType,
                                'bio': bioController.text.trim(),
                                'medicalHistory':
                                    medicalHistoryController.text.trim(),
                                'nextOfKinName':
                                    nextOfKinNameController.text.trim(),
                                'nextOfKinRelationship':
                                    nextOfKinRelationshipController.text.trim(),
                                'nextOfKinPhone':
                                    nextOfKinPhoneController.text.trim(),
                                'cellId': selectedCellId,
                                if (expectedCourtDateController.text
                                    .trim()
                                    .isNotEmpty)
                                  'expectedCourtDate':
                                      expectedCourtDateController.text.trim(),
                                if (nextOfKinEmailController.text
                                    .trim()
                                    .isNotEmpty)
                                  'nextOfKinEmail':
                                      nextOfKinEmailController.text.trim(),
                                if (homeOfOriginController.text
                                    .trim()
                                    .isNotEmpty)
                                  'homeOfOrigin':
                                      homeOfOriginController.text.trim(),
                              };
                              final created =
                                  await InmateApiService.createInmate(
                                inmate: inmate,
                                photo: _capturedPhotos.isEmpty
                                    ? null
                                    : _capturedPhotos.first,
                              );

                              if (selectedInmateType == 'SENTENCED') {
                                final createdId = created['id']?.toString();
                                if (createdId == null || createdId.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Inmate saved, but no API ID was returned for the sentence. Check the inmate list before trying again.',
                                      ),
                                    ),
                                  );
                                  navigator.pop(true);
                                  return;
                                }
                                String? endDate;
                                if (selectedSentenceType == 'FIXED_TERM') {
                                  final start = DateTime.parse(admissionDate);
                                  final years =
                                      int.parse(sentenceController.text.trim());
                                  endDate = _formatDate(
                                    DateTime(
                                      start.year + years,
                                      start.month,
                                      start.day,
                                    ),
                                  );
                                }
                                try {
                                  await InmateApiService.createSentence(
                                    inmateId: createdId,
                                    offence: offenceController.text.trim(),
                                    sentenceType: selectedSentenceType,
                                    startDate: admissionDate,
                                    endDate: endDate,
                                  );
                                } on ApiException catch (error) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Inmate saved, but the sentence failed: ${error.message}',
                                      ),
                                    ),
                                  );
                                  navigator.pop(true);
                                  return;
                                }
                              }
                            }

                            if (!mounted) return;
                            navigator.pop(true);
                          } on ApiException catch (error) {
                            if (!mounted) return;
                            if (!isEditing &&
                                (error.statusCode == null ||
                                    error.statusCode! >= 500)) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Registration could not be confirmed. Check the inmate list before retrying. ${error.message}',
                                  ),
                                ),
                              );
                              navigator.pop(true);
                              return;
                            }
                            setState(() => _isSaving = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                          } on FormatException catch (error) {
                            if (!mounted) return;
                            setState(() => _isSaving = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invalid date or sentence duration: $error',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    _isSaving
                        ? 'Saving...'
                        : isEditing
                            ? 'Update Changes'
                            : 'Save',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

class _CameraCaptureDialog extends StatefulWidget {
  final List<CameraDescription> cameras;

  const _CameraCaptureDialog({required this.cameras});

  @override
  State<_CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<_CameraCaptureDialog> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late int _selectedCameraIndex;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    // Default to rear camera on phones; fallback to first available camera
    final backIndex = widget.cameras.indexWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );
    _selectedCameraIndex = backIndex != -1 ? backIndex : 0;
    _initCamera(widget.cameras[_selectedCameraIndex]);
  }

  void _initCamera(CameraDescription cameraDescription) {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    await _controller.dispose();
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
      _initCamera(widget.cameras[_selectedCameraIndex]);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _snapPhoto() async {
    if (_isTakingPicture) return;
    setState(() => _isTakingPicture = true);

    try {
      await _initializeControllerFuture;
      final XFile file = await _controller.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.pop(context, bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTakingPicture = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to capture photo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Capture Inmate Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (widget.cameras.length > 1)
                      IconButton(
                        tooltip: 'Switch Camera',
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: _switchCamera,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_controller),
                    );
                  }
                  return const SizedBox(
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7a1f2d),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isTakingPicture ? null : _snapPhoto,
                icon: const Icon(Icons.camera),
                label: Text(_isTakingPicture ? 'Capturing...' : 'Take Photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

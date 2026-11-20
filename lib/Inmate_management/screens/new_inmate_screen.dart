import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';

import '../../database/db_helper.dart';
import '../models/inmate_model.dart';

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
  final TextEditingController prisonController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController offenceController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  String? selectedGender;
  final List<Uint8List> _capturedPhotos = [];
  final List<String> genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    if (widget.inmateToEdit != null) {
      final inmate = widget.inmateToEdit!;
      nameController.text = inmate.fullName;
      idController.text = inmate.id;
      prisonController.text = inmate.facility;
      dobController.text = inmate.dateOfBirth;
      offenceController.text = inmate.offenceCategory;
      sentenceController.text = inmate.sentenceYears.toString();
      selectedGender = inmate.gender;
      _capturedPhotos.addAll(inmate.photos);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    prisonController.dispose();
    dobController.dispose();
    offenceController.dispose();
    sentenceController.dispose();
    super.dispose();
  }

  // Opens the live camera viewfinder dialog (defaults to rear camera on mobile)
  Future<void> _captureInmatePhoto() async {
    if (_capturedPhotos.length >= 3) return;

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
              // 1. Inmate Photo Capture Section (Max 3)
              const Text(
                'Inmate Photos (Max 3)',
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
                        onPressed: _capturedPhotos.length < 3
                            ? _captureInmatePhoto
                            : null,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          _capturedPhotos.length < 3
                              ? 'Click here to capture inmate (${_capturedPhotos.length}/3)'
                              : 'Maximum 3 photos captured',
                        ),
                      ),
                    ),
                    if (_capturedPhotos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: _capturedPhotos.asMap().entries.map((entry) {
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
                validator: (val) =>
                    val!.trim().isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),

              // 3. ID / Prison Number (Entered by Record Officer)
              const Text(
                'ID / Prison Number',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: idController,
                readOnly: isEditing,
                decoration: InputDecoration(
                  hintText: 'Enter inmate ID / prison number',
                  filled: true,
                  fillColor: isEditing ? Colors.grey[200] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.trim().isEmpty
                    ? 'Please enter inmate ID / prison number'
                    : null,
              ),
              const SizedBox(height: 16),

              // 4. Allocate Prison (Not Predefined)
              const Text(
                'Allocate Prison',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: prisonController,
                decoration: InputDecoration(
                  hintText: 'Enter prison name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) =>
                    val!.trim().isEmpty ? 'Please enter prison name' : null,
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
                validator: (val) =>
                    val!.trim().isEmpty ? 'Please enter date of birth' : null,
              ),
              const SizedBox(height: 16),

              // 7. Offence (Not Predefined)
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
                validator: (val) =>
                    val!.trim().isEmpty ? 'Please enter an offence' : null,
              ),
              const SizedBox(height: 16),

              // 8. Sentence (years)
              const Text(
                'Sentence (years)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: sentenceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 5',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val!.trim().isEmpty
                    ? 'Please enter sentence duration'
                    : null,
              ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      DateTime dob = DateTime.parse(dobController.text.trim());
                      DateTime today = DateTime.now();
                      int age = today.year - dob.year;
                      if (today.month < dob.month ||
                          (today.month == dob.month && today.day < dob.day)) {
                        age--;
                      }

                      int sentenceYears = int.parse(
                        sentenceController.text.trim(),
                      );
                      DateTime calculatedReleaseDate = DateTime(
                        today.year + sentenceYears,
                        today.month,
                        today.day,
                      );

                      String formattedReleaseDate =
                          "${calculatedReleaseDate.year}-${calculatedReleaseDate.month.toString().padLeft(2, '0')}-${calculatedReleaseDate.day.toString().padLeft(2, '0')}";

                      // Check if inmate already has a prior record by matching Name + DOB
                      if (!isEditing) {
                        final existingInmates = DBHelper.getInmates();
                        final priorMatch = existingInmates.where(
                          (existing) =>
                              existing.fullName.toLowerCase().trim() ==
                                  nameController.text.toLowerCase().trim() &&
                              existing.dateOfBirth.trim() ==
                                  dobController.text.trim(),
                        );

                        if (priorMatch.isNotEmpty && context.mounted) {
                          final previous = priorMatch.first;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF7a1f2d),
                              duration: const Duration(seconds: 4),
                              content: Text(
                                'Returning Inmate Detected! Previous record (${previous.id}) was marked as "${previous.status}".',
                              ),
                            ),
                          );
                        }
                      }

                      final inmateModel = InmateModel(
                        id: idController.text.trim(),
                        fullName: nameController.text.trim(),
                        gender: selectedGender!,
                        age: age,
                        dateOfBirth: dobController.text.trim(),
                        nationality:
                            widget.inmateToEdit?.nationality ?? 'Malawian',
                        facility: prisonController.text.trim(),
                        offenceCategory: offenceController.text.trim(),
                        sentenceYears: sentenceYears,
                        releaseDate: formattedReleaseDate,
                        status: widget.inmateToEdit?.status ?? 'Active',
                        photos: List<Uint8List>.from(_capturedPhotos),
                      );

                      await DBHelper.addInmate(inmateModel);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    isEditing ? 'Update Changes' : 'Save',
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

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
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
  final TextEditingController dobController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  String? selectedGender;
  String? selectedOffence;

  final List<String> genders = ['Male', 'Female'];
  final List<String> offences = [
    'Theft',
    'Fraud',
    'Assault',
    'Robbery',
    'Homicide',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.inmateToEdit != null) {
      final inmate = widget.inmateToEdit!;
      nameController.text = inmate.fullName;
      idController.text = inmate.id;
      dobController.text = inmate.dateOfBirth;
      sentenceController.text = inmate.sentenceYears
          .toString(); // <-- Populates existing sentence years!
      selectedGender = inmate.gender;
      selectedOffence = inmate.offenceCategory;
    } else {
      idController.text = 'MP/00${DateTime.now().second * 37 % 900 + 100}';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.inmateToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF344b3b), // Dark Green Header
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
                    val!.isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'ID / Prison Number',
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
              const SizedBox(height: 16),
              const Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGender,
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
                    val!.isEmpty ? 'Please enter date of birth' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Offence',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedOffence,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text('Select Offence Category'),
                items: offences
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (val) => setState(() => selectedOffence = val),
                validator: (val) =>
                    val == null ? 'Please select an offence' : null,
              ),
              const SizedBox(height: 16),
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
                validator: (val) =>
                    val!.isEmpty ? 'Please enter sentence duration' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7a1f2d), // Burgundy Button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      DateTime dob = DateTime.parse(dobController.text);
                      DateTime today = DateTime.now();
                      int age = today.year - dob.year;
                      if (today.month < dob.month ||
                          (today.month == dob.month && today.day < dob.day)) {
                        age--;
                      }

                      int sentenceYears = int.parse(sentenceController.text);
                      DateTime calculatedReleaseDate = DateTime(
                        today.year + sentenceYears,
                        today.month,
                        today.day,
                      );

                      String formattedReleaseDate =
                          "${calculatedReleaseDate.year}-${calculatedReleaseDate.month.toString().padLeft(2, '0')}-${calculatedReleaseDate.day.toString().padLeft(2, '0')}";

                      final inmateModel = InmateModel(
                        id: idController.text,
                        fullName: nameController.text,
                        gender: selectedGender!,
                        age: age,
                        dateOfBirth: dobController.text,
                        nationality:
                            widget.inmateToEdit?.nationality ?? 'Malawian',
                        facility:
                            widget.inmateToEdit?.facility ?? 'Zomba Central',
                        offenceCategory: selectedOffence!,
                        sentenceYears:
                            sentenceYears, // Updated sentence duration
                        releaseDate: formattedReleaseDate, // Recalculated release date based on new sentence
                        status: widget.inmateToEdit?.status ?? 'Active',
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

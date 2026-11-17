import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../models/transfer_model.dart';

class TransferRequestScreen extends StatefulWidget {
  const TransferRequestScreen({Key? key}) : super(key: key);

  @override
  _TransferRequestScreenState createState() => _TransferRequestScreenState();
}

class _TransferRequestScreenState extends State<TransferRequestScreen> {
  int _currentIndex = 2; // Highlights 'Transfer' tab

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inmateNameController = TextEditingController();
  final TextEditingController _inmateIdController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedSourcePrisonId;
  String? _selectedSourcePrisonName;
  String? _selectedDestinationPrisonId;
  String? _selectedDestinationPrisonName;
  String? _selectedGender;
  final String _status = "PENDING";

  // Clean list for registered prisons ready for backend integration (no mock data)
  var _registeredPrisons = [];

  @override
  void initState() {
    super.initState();
    _fetchRegisteredPrisons();
  }

  Future<void> _fetchRegisteredPrisons() async {
    // TODO: Connect to backend API to fetch registered prisons dynamically
    setState(() {
      _registeredPrisons = []; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2E20),
        automaticallyImplyLeading: false,
        title: const Text('Transfer Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fill in the details below to request a transfer',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _inmateNameController,
                decoration: const InputDecoration(
                  labelText: 'Inmate Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter inmate name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _inmateIdController,
                decoration: const InputDecoration(
                  labelText: 'Inmate ID',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter inmate ID' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Current Prison (Source)',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: _registeredPrisons.map((prison) {
                  return DropdownMenuItem<String>(
                    value: prison['id']?.toString(),
                    child: Text(prison['name']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSourcePrisonId = val;
                    final match = _registeredPrisons.firstWhere(
                      (p) => p['id'].toString() == val,
                      orElse: () => {},
                    );
                    _selectedSourcePrisonName = match['name']?.toString();
                  });
                },
                validator: (val) => val == null ? 'Please select source prison' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Requested Prison (Destination)',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: _registeredPrisons.map((prison) {
                  return DropdownMenuItem<String>(
                    value: prison['id']?.toString(),
                    child: Text(prison['name']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDestinationPrisonId = val;
                    final match = _registeredPrisons.firstWhere(
                      (p) => p['id'].toString() == val,
                      orElse: () => {},
                    );
                    _selectedDestinationPrisonName = match['name']?.toString();
                  });
                },
                validator: (val) => val == null ? 'Please select destination prison' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
                validator: (val) => val == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason for Transfer',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter transfer reason' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(_status),
                    backgroundColor: Colors.lightGreen.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A1F2D), // Consistent burgundy/maroon theme
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitTransferRequest,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text('Submit Request', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  void _submitTransferRequest() {
    if (_formKey.currentState!.validate()) {
      final payload = TransferRequestPayload(
        inmateId: _inmateIdController.text,
        inmateName: _inmateNameController.text,
        sourcePrisonId: _selectedSourcePrisonId ?? '',
        sourcePrisonName: _selectedSourcePrisonName ?? '',
        destinationPrisonId: _selectedDestinationPrisonId ?? '',
        destinationPrisonName: _selectedDestinationPrisonName ?? '',
        reason: _reasonController.text,
        status: _status,
      );

      // Submit payload to POST /api/v1/transfers
      print(payload.toJson());
    }
  }
}
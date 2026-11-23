import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../services/program_facilitator_service.dart';

class RehabilitationScreen extends StatefulWidget {
  final Map<String, Object?>? user;
  final int initialTab;

  const RehabilitationScreen({
    super.key,
    this.user,
    this.initialTab = 0,
  });

  @override
  State<RehabilitationScreen> createState() => _RehabilitationScreenState();
}

class _RehabilitationScreenState extends State<RehabilitationScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A1F2D);

  int _selectedTab = 0;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _programmes = [];
  List<Map<String, dynamic>> _enrollments = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _inmates = [];

  bool get _readOnly {
    final role = widget.user?['role']?.toString().toLowerCase().trim();
    return role == 'commissioner' || role == 'prison commissioner';
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        ProgramFacilitatorApiService.getPrograms(),
        ProgramFacilitatorApiService.getEnrollments(),
        ProgramFacilitatorApiService.getAttendance(),
        ApiClient.instance.getAllPages('/inmates'),
      ]);
      if (!mounted) return;
      setState(() {
        _programmes = results[0];
        _enrollments = results[1];
        _attendance = results[2];
        _inmates = results[3];
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  String _date(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _inmateName(Map<String, dynamic> inmate) {
    final first = inmate['firstName']?.toString() ?? '';
    final last = inmate['lastName']?.toString() ?? '';
    final fullName = '$first $last'.trim();
    return fullName.isEmpty ? (inmate['id']?.toString() ?? 'Inmate') : fullName;
  }

  Future<void> _showCreateProgrammeDialog() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final schedule = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Programme'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a programme name'
                        : null,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: schedule,
                    decoration: const InputDecoration(labelText: 'Schedule'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      try {
                        await ProgramFacilitatorApiService.createProgram(
                          name: name.text.trim(),
                          description: description.text.trim(),
                          schedule: schedule.text.trim(),
                          instructorUserId: widget.user?['id']?.toString(),
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        await _load();
                      } on ApiException catch (error) {
                        if (!dialogContext.mounted) return;
                        setDialogState(() => saving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      }
                    },
              child: Text(saving ? 'Saving...' : 'Create'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    description.dispose();
    schedule.dispose();
  }

  Future<void> _showEnrollmentDialog(
    Map<String, dynamic> programme,
  ) async {
    final programId = programme['id']?.toString();
    if (programId == null || programId.isEmpty) return;
    String? inmateId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Enroll in ${programme['name'] ?? 'Programme'}'),
          content: _inmates.isEmpty
              ? const Text('No inmate records are available.')
              : DropdownButtonFormField<String>(
                  initialValue: inmateId,
                  decoration: const InputDecoration(labelText: 'Inmate'),
                  items: _inmates.map((inmate) {
                    final id = inmate['id']?.toString() ?? '';
                    return DropdownMenuItem(
                      value: id,
                      child: Text(_inmateName(inmate)),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => inmateId = value),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: inmateId == null
                  ? null
                  : () async {
                      try {
                        await ProgramFacilitatorApiService.createEnrollment(
                          inmateId: inmateId!,
                          programId: programId,
                          enrollmentDate: _date(DateTime.now()),
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        await _load();
                      } on ApiException catch (error) {
                        if (!dialogContext.mounted) return;
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      }
                    },
              child: const Text('Confirm Enrollment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttendanceDialog() async {
    if (_programmes.isEmpty || _enrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a programme and enroll an inmate first.'),
        ),
      );
      return;
    }

    String? enrollmentId;
    String attendanceStatus = '';
    String remarks = '';
    final statusController = TextEditingController();
    final remarksController = TextEditingController();
    final sessionDateController =
        TextEditingController(text: _date(DateTime.now()));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final enrollment = _enrollments.where(
            (item) => item['id']?.toString() == enrollmentId,
          );
          final selected = enrollment.isEmpty ? null : enrollment.first;
          return AlertDialog(
            title: const Text('Record Attendance'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: enrollmentId,
                    decoration: const InputDecoration(
                      labelText: 'Enrolled inmate',
                    ),
                    items: _enrollments.map((item) {
                      final id = item['id']?.toString() ?? '';
                      final label =
                          '${item['inmateName'] ?? item['inmateId']} — '
                          '${item['programName'] ?? item['programId']}';
                      return DropdownMenuItem(value: id, child: Text(label));
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => enrollmentId = value),
                  ),
                  TextFormField(
                    controller: sessionDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Session date',
                    ),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: dialogContext,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.tryParse(
                              sessionDateController.text,
                            ) ??
                            DateTime.now(),
                      );
                      if (selectedDate != null) {
                        sessionDateController.text = _date(selectedDate);
                      }
                    },
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(
                      labelText: 'Attendance status',
                      helperText: 'Enter a status accepted by the API.',
                    ),
                    onChanged: (value) => attendanceStatus = value.trim(),
                  ),
                  TextField(
                    controller: remarksController,
                    decoration: const InputDecoration(labelText: 'Remarks'),
                    onChanged: (value) => remarks = value.trim(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selected == null || attendanceStatus.isEmpty
                    ? null
                    : () async {
                        try {
                          await ProgramFacilitatorApiService.recordAttendance(
                            inmateId: selected['inmateId'].toString(),
                            programId: selected['programId'].toString(),
                            sessionDate: sessionDateController.text,
                            attendanceStatus: attendanceStatus,
                            remarks: remarks,
                          );
                          if (!mounted || !dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          await _load();
                        } on ApiException catch (error) {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
                      },
                child: const Text('Save Attendance'),
              ),
            ],
          );
        },
      ),
    );

    statusController.dispose();
    remarksController.dispose();
    sessionDateController.dispose();
  }

  int _enrollmentCount(String programId) {
    return _enrollments
        .where((enrollment) => enrollment['programId']?.toString() == programId)
        .length;
  }

  String _attendanceInmateName(Map<String, dynamic> record) {
    final enrollmentId = record['enrollmentId']?.toString();
    for (final enrollment in _enrollments) {
      if (enrollment['id']?.toString() == enrollmentId) {
        return enrollment['inmateName']?.toString() ??
            enrollment['inmateId']?.toString() ??
            'Inmate';
      }
    }
    return 'Inmate';
  }

  Widget _buildProgrammeList() {
    if (_programmes.isEmpty) {
      return const Center(child: Text('No programmes found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _programmes.length,
      itemBuilder: (context, index) {
        final programme = _programmes[index];
        final id = programme['id']?.toString() ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.menu_book_outlined, color: deepGreen),
            title: Text(programme['name']?.toString() ?? 'Programme'),
            subtitle: Text(
              '${programme['description'] ?? ''}\n'
              '${_enrollmentCount(id)} participants'
              '${programme['schedule'] == null ? '' : ' • ${programme['schedule']}'}',
            ),
            isThreeLine: true,
            trailing: _readOnly ? null : IconButton(
              tooltip: 'Enroll inmate',
              onPressed: () => _showEnrollmentDialog(programme),
              icon: const Icon(Icons.person_add_alt_1, color: maroon),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    if (_attendance.isEmpty) {
      return const Center(child: Text('No attendance records found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendance.length,
      itemBuilder: (context, index) {
        final record = _attendance[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.fact_check_outlined, color: maroon),
            title: Text(_attendanceInmateName(record)),
            subtitle: Text(
              '${record['sessionDate'] ?? ''} • '
              '${record['attendanceStatus'] ?? ''}'
              '${record['remarks'] == null ? '' : '\n${record['remarks']}'}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: deepGreen,
        title: const Text(
          'Rehabilitation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_readOnly && _selectedTab == 0)
            IconButton(
              tooltip: 'Create programme',
              onPressed: _showCreateProgrammeDialog,
              icon: const Icon(Icons.add),
            ),
          if (!_readOnly && _selectedTab == 1)
            IconButton(
              tooltip: 'Record attendance',
              onPressed: _showAttendanceDialog,
              icon: const Icon(Icons.fact_check_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Programs',
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Attendance',
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: deepGreen),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _selectedTab == 0
                        ? _buildProgrammeList()
                        : _buildAttendanceList(),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF344B3B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../authentication/screens/auth_services/auth_service.dart';
import '../../core/api/api_client.dart';
import '../../services/roster_service.dart';

class DutyRosterScreen extends StatefulWidget {
  final bool readOnly;
  const DutyRosterScreen({super.key, this.readOnly = false});

  @override
  State<DutyRosterScreen> createState() => _DutyRosterScreenState();
}

class _DutyRosterScreenState extends State<DutyRosterScreen> {
  static const green = Color(0xFF344B3B);
  late Future<List<Map<String, dynamic>>> _rosters;

  @override
  void initState() {
    super.initState();
    _rosters = RosterApiService.getRosters();
  }

  Future<void> _refresh() async {
    final future = RosterApiService.getRosters();
    setState(() => _rosters = future);
    await future;
  }

  Future<void> _createRoster() async {
    final start = DateTime.now();
    final end = start.add(const Duration(days: 7));
    final startController = TextEditingController(text: _date(start));
    final endController = TextEditingController(text: _date(end));
    final form = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create duty roster'),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Start date (YYYY-MM-DD)'),
              validator: _validDate,
            ),
            TextFormField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'End date (YYYY-MM-DD)'),
              validator: _validDate,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              try {
                final user = AuthService.currentUser ?? const <String, dynamic>{};
                await RosterApiService.createRoster(
                  periodStart: startController.text.trim(),
                  periodEnd: endController.text.trim(),
                  prisonId: user['prisonId']?.toString(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Could not create roster: $error')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    startController.dispose();
    endController.dispose();
    if (result == true && mounted) await _refresh();
  }

  String? _validDate(String? value) {
    if (DateTime.tryParse(value?.trim() ?? '') == null) {
      return 'Enter a valid date as YYYY-MM-DD';
    }
    return null;
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Duty Roster'),
          backgroundColor: green,
          foregroundColor: Colors.white,
          actions: [
            if (!widget.readOnly)
              IconButton(onPressed: _createRoster, icon: const Icon(Icons.add), tooltip: 'Create roster'),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _rosters,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(children: [
                  const SizedBox(height: 120),
                  Center(child: Text('Could not load rosters: ${snapshot.error}')),
                  Center(child: TextButton(onPressed: _refresh, child: const Text('Retry'))),
                ]);
              }
              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return ListView(children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No duty rosters yet. Create one to assign shifts.')),
                ]);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final roster = records[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month, color: green),
                      title: Text('${roster['periodStart'] ?? ''} – ${roster['periodEnd'] ?? ''}'),
                      subtitle: Text('Status: ${roster['status'] ?? 'DRAFT'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute<void>(
                          builder: (_) => DutyRosterDetailScreen(
                            rosterId: roster['id'].toString(),
                            readOnly: widget.readOnly,
                          ),
                        ));
                        if (mounted) await _refresh();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
}

class DutyRosterDetailScreen extends StatefulWidget {
  final String rosterId;
  final bool readOnly;
  const DutyRosterDetailScreen({super.key, required this.rosterId, this.readOnly = false});

  @override
  State<DutyRosterDetailScreen> createState() => _DutyRosterDetailScreenState();
}

class _DutyRosterDetailScreenState extends State<DutyRosterDetailScreen> {
  static const green = Color(0xFF344B3B);
  late Future<Map<String, dynamic>> _roster;

  @override
  void initState() {
    super.initState();
    _roster = RosterApiService.getRoster(widget.rosterId);
  }

  Future<void> _reload() async {
    final future = RosterApiService.getRoster(widget.rosterId);
    setState(() => _roster = future);
    await future;
  }

  Future<void> _publish() async {
    try {
      await RosterApiService.publish(widget.rosterId);
      await _reload();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish roster: $error')));
    }
  }

  Future<void> _addShift() async {
    try {
      final users = await ApiClient.instance.getAllPages('/users');
      final staff = users.where((user) {
        final role = user['role']?.toString().toLowerCase() ?? '';
        return role.contains('officer') || role.contains('guard') || role.contains('worker');
      }).toList();
      if (!mounted) return;
      if (staff.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No guards or staff accounts were returned by the API.')));
        return;
      }
      Map<String, dynamic>? selected = staff.first;
      final start = DateTime.now().add(const Duration(hours: 1));
      final end = start.add(const Duration(hours: 8));
      final location = TextEditingController();
      final form = GlobalKey<FormState>();
      final created = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Assign duty shift'),
          content: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Staff member'),
                items: staff.map((user) => DropdownMenuItem(
                  value: user,
                  child: Text(user['fullName']?.toString() ?? user['username']?.toString() ?? 'Staff'),
                )).toList(),
                onChanged: (value) => selected = value,
              ),
              TextFormField(controller: location, decoration: const InputDecoration(labelText: 'Location'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a location' : null),
              const Padding(padding: EdgeInsets.only(top: 12), child: Text('Shift defaults to 8 hours starting one hour from now.')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () async {
              if (!form.currentState!.validate() || selected == null) return;
              try {
                await RosterApiService.addShift(
                  rosterId: widget.rosterId,
                  officerId: selected!['id'].toString(),
                  startAt: start.toIso8601String(),
                  endAt: end.toIso8601String(),
                  location: location.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (error) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Could not assign shift: $error')));
              }
            }, child: const Text('Assign')),
          ],
        ),
      );
      location.dispose();
      if (created == true && mounted) await _reload();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load staff: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Roster details'), backgroundColor: green, foregroundColor: Colors.white),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _roster,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Could not load roster: ${snapshot.error}'));
            final roster = snapshot.data!;
            final shifts = (roster['shifts'] as List? ?? const []).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
            final isDraft = roster['status']?.toString().toUpperCase() == 'DRAFT';
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('${roster['periodStart'] ?? ''} – ${roster['periodEnd'] ?? ''}', style: Theme.of(context).textTheme.titleLarge),
                  Text('Status: ${roster['status'] ?? ''}'),
                  const SizedBox(height: 16),
                  if (shifts.isEmpty) const Text('No shifts assigned yet.'),
                  ...shifts.map((shift) => Card(child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(shift['officerName']?.toString() ?? 'Assigned staff'),
                    subtitle: Text('${shift['startAt'] ?? ''} – ${shift['endAt'] ?? ''}\n${shift['location'] ?? ''}'),
                    isThreeLine: true,
                  ))),
                  if (isDraft && !widget.readOnly) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(onPressed: _addShift, icon: const Icon(Icons.person_add_alt_1), label: const Text('Assign staff shift')),
                    OutlinedButton.icon(onPressed: shifts.isEmpty ? null : _publish, icon: const Icon(Icons.publish), label: const Text('Publish roster')),
                  ],
                ],
              ),
            );
          },
        ),
      );
}

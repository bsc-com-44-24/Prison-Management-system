import 'package:material_ui/material_ui.dart';

import '../../authentication/screens/auth_services/auth_service.dart';
import '../../core/api/api_client.dart';
import '../../services/inmate_service.dart';

class ApiReleaseScreen extends StatefulWidget {
  const ApiReleaseScreen({super.key});

  @override
  State<ApiReleaseScreen> createState() => _ApiReleaseScreenState();
}

class _ApiReleaseScreenState extends State<ApiReleaseScreen> {
  static const green = Color(0xFF344B3B);
  List<Map<String, dynamic>> releases = [];
  bool loading = true;
  String? error;

  bool get canApprove {
    final role = AuthService.currentUser?['role']?.toString().toLowerCase();
    return role == 'commissioner' || role == 'prison commissioner' ||
        role == 'admin' || role == 'super admin' ||
        role == 'system admin' || role == 'system administrator';
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final inmates = await ApiClient.instance.getAllPages('/inmates');
      final results = await Future.wait(inmates.map((inmate) async {
        final id = inmate['id']?.toString();
        if (id == null || id.isEmpty) return <Map<String, dynamic>>[];
        final response = await ApiClient.instance.get('/inmates/$id/sentences');
        if (response is! List) return <Map<String, dynamic>>[];
        return response.whereType<Map>().map((sentence) => {
          'inmate': inmate,
          'sentence': Map<String, dynamic>.from(sentence),
        }).toList();
      }));
      final records = results.expand((items) => items).where((record) {
        final sentence = record['sentence'] as Map<String, dynamic>;
        return sentence['endDate'] != null;
      }).toList();
      if (!mounted) return;
      setState(() { releases = records; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> _approve(Map<String, dynamic> record) async {
    final inmate = record['inmate'] as Map<String, dynamic>;
    final sentence = record['sentence'] as Map<String, dynamic>;
    final due = DateTime.tryParse(sentence['endDate']?.toString() ?? '');
    if (due == null || due.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This sentence has not reached its release date.')));
      return;
    }
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Approve discharge'),
      content: Text('Approve release of ${inmate['firstName']} ${inmate['lastName']}? This calls the backend discharge action.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve & Discharge'))],
    ));
    if (confirm != true) return;
    try {
      await InmateApiService.dischargeInmate(inmate['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discharge recorded by the backend.')));
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Discharge failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Release Management'), backgroundColor: green, foregroundColor: Colors.white),
    body: loading ? const Center(child: CircularProgressIndicator()) : error != null
      ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Could not load release records: $error'), TextButton(onPressed: _load, child: const Text('Retry'))])))
      : RefreshIndicator(onRefresh: _load, child: releases.isEmpty
        ? ListView(children: const [SizedBox(height: 180), Center(child: Text('No sentenced inmates with release dates were found.'))])
        : ListView.builder(padding: const EdgeInsets.all(12), itemCount: releases.length, itemBuilder: (context, index) {
          final record = releases[index];
          final inmate = record['inmate'] as Map<String, dynamic>;
          final sentence = record['sentence'] as Map<String, dynamic>;
          final due = DateTime.tryParse(sentence['endDate'].toString());
          final isDue = due != null && !due.isAfter(DateTime.now());
          return Card(child: ListTile(
            leading: const Icon(Icons.assignment_outlined, color: green),
            title: Text('${inmate['firstName'] ?? ''} ${inmate['lastName'] ?? ''}'),
            subtitle: Text('Release date: ${sentence['endDate']}\nOffence: ${sentence['offence'] ?? 'Not specified'} · ${sentence['status'] ?? ''}'),
            isThreeLine: true,
            trailing: canApprove ? TextButton(onPressed: isDue ? () => _approve(record) : null, child: const Text('Approve')) : null,
          ));
        })),
  );
}

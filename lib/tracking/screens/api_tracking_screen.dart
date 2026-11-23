import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';

class ApiTrackingScreen extends StatefulWidget {
  const ApiTrackingScreen({super.key});

  @override
  State<ApiTrackingScreen> createState() => _ApiTrackingScreenState();
}

class _ApiTrackingScreenState extends State<ApiTrackingScreen> {
  static const green = Color(0xFF344B3B);
  final _search = TextEditingController();
  List<Map<String, dynamic>> _inmates = [];
  Map<String, Map<String, dynamic>> _cells = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Future.wait([
        ApiClient.instance.getAllPages('/inmates'),
        ApiClient.instance.getAllPages('/cells'),
      ]);
      final inmates = result[0];
      final cells = {for (final cell in result[1]) cell['id'].toString(): cell};
      if (!mounted) return;
      setState(() {
        _inmates = inmates;
        _cells = cells;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _name(Map<String, dynamic> inmate) =>
      '${inmate['firstName'] ?? ''} ${inmate['lastName'] ?? ''}'.trim();

  void _showDetails(Map<String, dynamic> inmate) {
    final cellId = inmate['cellId']?.toString() ?? '';
    final cell = _cells[cellId];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_name(inmate)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Prison: ${inmate['prisonName'] ?? 'Not assigned'}'),
          Text('Block: ${cell?['blockName'] ?? 'Not assigned'}'),
          Text('Cell: ${cell?['name'] ?? cell?['cellNumber'] ?? 'Not assigned'}'),
          Text('Inmate type: ${inmate['inmateType'] ?? 'Unknown'}'),
          Text('Admission date: ${inmate['admissionDate'] ?? 'Unknown'}'),
          Text('Record updated: ${inmate['updatedAt'] ?? 'Unknown'}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final records = _inmates.where((inmate) {
      return _name(inmate).toLowerCase().contains(query) ||
          inmate['id'].toString().toLowerCase().contains(query) ||
          (inmate['prisonName']?.toString().toLowerCase().contains(query) ?? false);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Inmate Tracking'), backgroundColor: green, foregroundColor: Colors.white),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search inmates, ID, or prison'),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Tracking data failed to load: $_error'), TextButton(onPressed: _load, child: const Text('Retry'))])))
                  : records.isEmpty
                      ? const Center(child: Text('No matching inmate records.'))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final inmate = records[index];
                              final cell = _cells[inmate['cellId']?.toString() ?? ''];
                              return Card(
                                margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                                child: ListTile(
                                  leading: const CircleAvatar(backgroundColor: Color(0xFFE8EFEA), child: Icon(Icons.badge_outlined, color: green)),
                                  title: Text(_name(inmate)),
                                  subtitle: Text('${inmate['prisonName'] ?? 'Prison unassigned'} · ${cell?['blockName'] ?? 'Block unassigned'} · ${cell?['name'] ?? 'Cell unassigned'}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _showDetails(inmate),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}

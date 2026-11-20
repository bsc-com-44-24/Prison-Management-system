import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_client.dart';
import '../../../services/commissioner_service.dart';

class CommissionerTransfersScreen extends StatefulWidget {
  final bool pendingOnly;

  const CommissionerTransfersScreen({
    super.key,
    this.pendingOnly = false,
  });

  @override
  State<CommissionerTransfersScreen> createState() =>
      _CommissionerTransfersScreenState();
}

class _CommissionerTransfersScreenState
    extends State<CommissionerTransfersScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);

  final CommissionerApiService _api = CommissionerApiService();
  List<Map<String, dynamic>> _transfers = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transfers = await _api.getTransfers(
        status: widget.pendingOnly ? 'PENDING' : null,
      );
      if (!mounted) return;
      setState(() {
        _transfers = transfers;
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

  Future<void> _decideTransfer(
    Map<String, dynamic> transfer, {
    required bool approve,
  }) async {
    final id = transfer['id']?.toString();
    if (id == null || id.isEmpty) {
      _showMessage('This transfer has no API identifier.');
      return;
    }

    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve transfer?' : 'Reject transfer?'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Decision note (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, noteController.text.trim()),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    noteController.dispose();

    if (note == null || !mounted) return;
    setState(() => _updatingIds.add(id));

    try {
      if (approve) {
        await _api.approveTransfer(id, note: note);
      } else {
        await _api.rejectTransfer(id, note: note);
      }

      if (!mounted) return;
      _showMessage(approve ? 'Transfer approved.' : 'Transfer rejected.');
      await _loadTransfers();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _updatingIds.remove(id));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _value(Map<String, dynamic> transfer, String key) {
    final value = transfer[key]?.toString().trim();
    return value == null || value.isEmpty ? 'Not provided' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F3),
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title:
            Text(widget.pendingOnly ? 'Transfer Requests' : 'Transfer History'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransfers,
        child: _isLoading
            ? ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: _loadTransfers,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  )
                : _transfers.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(
                            height: 300,
                            child: Center(
                                child: Text('No transfer records found.')),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transfers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final transfer = _transfers[index];
                          final id = transfer['id']?.toString() ?? '';
                          final status =
                              _value(transfer, 'status').toUpperCase();
                          final isPending = status == 'PENDING';
                          final isUpdating = _updatingIds.contains(id);

                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.swap_horiz,
                                          color: deepGreen),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _value(transfer, 'inmateName'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(status),
                                        backgroundColor: status == 'PENDING'
                                            ? Colors.orange.shade100
                                            : Colors.grey.shade200,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'From: ${_value(transfer, 'sourcePrisonName')}',
                                  ),
                                  Text(
                                    'To: ${_value(transfer, 'destinationPrisonName')}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Reason: ${_value(transfer, 'reason')}'),
                                  if (isPending) ...[
                                    const SizedBox(height: 12),
                                    if (isUpdating)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _decideTransfer(
                                                transfer,
                                                approve: false,
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: maroon,
                                              ),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _decideTransfer(
                                                transfer,
                                                approve: true,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: deepGreen,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Approve'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class CommissionerNotificationsScreen extends StatefulWidget {
  const CommissionerNotificationsScreen({super.key});

  @override
  State<CommissionerNotificationsScreen> createState() =>
      _CommissionerNotificationsScreenState();
}

class _CommissionerNotificationsScreenState
    extends State<CommissionerNotificationsScreen> {
  static const Color deepGreen = Color(0xFF344B3B);

  final CommissionerApiService _api = CommissionerApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notifications = await _api.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
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

  Future<void> _markRead(Map<String, dynamic> notification) async {
    final id = notification['id']?.toString();
    if (id == null || id.isEmpty) return;

    try {
      await _api.markNotificationRead(id);
      await _loadNotifications();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      await _loadNotifications();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F3),
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Read all',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  )
                : _notifications.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(
                            height: 300,
                            child: Center(child: Text('No notifications.')),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final isRead = item['isRead'] == true;
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                isRead
                                    ? Icons.notifications_none
                                    : Icons.notifications_active_outlined,
                                color: deepGreen,
                              ),
                              title: Text(
                                item['title']?.toString() ?? 'Notification',
                              ),
                              subtitle: Text(
                                item['message']?.toString() ?? '',
                              ),
                              trailing: isRead
                                  ? null
                                  : TextButton(
                                      onPressed: () => _markRead(item),
                                      child: const Text('Mark read'),
                                    ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

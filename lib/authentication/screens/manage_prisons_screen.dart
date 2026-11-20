
import 'package:material_ui/material_ui.dart';

class ManagePrisonsScreen extends StatefulWidget {
  final List<Map<String, String>> initialPrisons;

  const ManagePrisonsScreen({
    super.key,
    this.initialPrisons = const [],
  });

  @override
  State<ManagePrisonsScreen> createState() =>
      _ManagePrisonsScreenState();
}

class _Prison {
  String prisonId;
  String prisonName;
  String prisonLocation;

  _Prison({
    required this.prisonId,
    required this.prisonName,
    required this.prisonLocation,
  });

  factory _Prison.fromMap(Map<String, String> map) {
    return _Prison(
      prisonId: map['prisonId'] ?? '',
      prisonName: map['prisonName'] ?? '',
      prisonLocation: map['prisonLocation'] ?? '',
    );
  }
}

class _ManagePrisonsScreenState extends State<ManagePrisonsScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color background = Color(0xFFF4F5F3);

  final TextEditingController searchController =
      TextEditingController();

  late List<_Prison> prisons;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    prisons = widget.initialPrisons
        .map((prison) => _Prison.fromMap(prison))
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_Prison> get filteredPrisons {
    if (searchQuery.trim().isEmpty) return prisons;

    final query = searchQuery.toLowerCase();

    return prisons.where((prison) {
      return prison.prisonId.toLowerCase().contains(query) ||
          prison.prisonName.toLowerCase().contains(query) ||
          prison.prisonLocation.toLowerCase().contains(query);
    }).toList();
  }

  // ADD OR EDIT PRISON

  void showPrisonForm({_Prison? prison}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PrisonFormDialog(
          prison: prison,
          onSave: (id, name, location) {
            setState(() {
              if (prison == null) {
                prisons.add(
                  _Prison(
                    prisonId: id,
                    prisonName: name,
                    prisonLocation: location,
                  ),
                );
              } else {
                prison.prisonId = id;
                prison.prisonName = name;
                prison.prisonLocation = location;
              }
            });

            Navigator.pop(dialogContext);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  prison == null
                      ? 'Prison registered successfully'
                      : 'Prison details updated successfully',
                ),
                backgroundColor: deepGreen,
              ),
            );
          },
        );
      },
    );
  }

  // PRISON ACTIONS

  void showPrisonActions(_Prison prison) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      deepGreen.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.account_balance,
                    size: 30,
                    color: deepGreen,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  prison.prisonName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: deepGreen,
                  ),
                ),

                Text(
                  prison.prisonId,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: deepGreen,
                  ),
                  title: const Text(
                    'Edit Prison',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Update prison information',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showPrisonForm(prison: prison);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: maroon,
                  ),
                  title: const Text(
                    'Delete Prison',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Remove this prison',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showDeleteConfirmation(prison);
                  },
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: deepGreen,
                      side: const BorderSide(color: deepGreen),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DELETE CONFIRMATION

  void showDeleteConfirmation(_Prison prison) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    maroon.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.delete_outline,
                  size: 34,
                  color: maroon,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Delete Prison?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: maroon,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Are you sure you want to permanently delete this prison?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 14),

              Text(
                prison.prisonName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Text(
                'Prison ID: ${prison.prisonId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: deepGreen,
                        side: const BorderSide(
                          color: deepGreen,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          prisons.remove(prison);
                        });

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Prison deleted successfully',
                            ),
                            backgroundColor: deepGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      child: const Text('Yes, Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedPrisons = filteredPrisons;

    return Scaffold(
      backgroundColor: background,

      // HEADER

      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/loggg.jpg',
              height: 38,
              width: 38,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Manage Prisons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      // BODY

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 18, 16, 12,
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search prisons...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: deepGreen,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchQuery = '');
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            if (prisons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: deepGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance,
                        color: deepGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Registered Prisons: ${prisons.length}',
                        style: const TextStyle(
                          color: deepGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: prisons.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              size: 85,
                              color: deepGreen,
                            ),
                            SizedBox(height: 18),
                            Text(
                              'No Prisons Found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: deepGreen,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'There are currently no prisons registered in the system.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : displayedPrisons.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching prisons found',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            16, 4, 16, 100,
                          ),
                          itemCount: displayedPrisons.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final prison =
                                displayedPrisons[index];

                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(16),
                                onTap: () =>
                                    showPrisonActions(prison),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: deepGreen
                                            .withValues(alpha: 0.10),
                                        child: const Icon(
                                          Icons.account_balance,
                                          color: deepGreen,
                                          size: 27,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prison.prisonName,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),

                                            const SizedBox(height: 5),

                                            Text(
                                              'ID: ${prison.prisonId}',
                                              style: TextStyle(
                                                color: Colors
                                                    .grey.shade700,
                                                fontSize: 12,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 15,
                                                  color: Colors
                                                      .grey.shade600,
                                                ),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(
                                                    prison.prisonLocation,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons.more_vert,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // FLOATING ADD BUTTON

      floatingActionButton: FloatingActionButton(
        onPressed: () => showPrisonForm(),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
    );
  }
}

// ADD / EDIT PRISON OVERLAY

class _PrisonFormDialog extends StatefulWidget {
  final _Prison? prison;

  final Function(
    String prisonId,
    String prisonName,
    String prisonLocation,
  ) onSave;

  const _PrisonFormDialog({
    required this.prison,
    required this.onSave,
  });

  @override
  State<_PrisonFormDialog> createState() =>
      _PrisonFormDialogState();
}

class _PrisonFormDialogState extends State<_PrisonFormDialog> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);

  final formKey = GlobalKey<FormState>();

  late final TextEditingController prisonIdController;
  late final TextEditingController prisonNameController;
  late final TextEditingController prisonLocationController;

  bool get isEditing => widget.prison != null;

  @override
  void initState() {
    super.initState();

    prisonIdController = TextEditingController(
      text: widget.prison?.prisonId ?? '',
    );

    prisonNameController = TextEditingController(
      text: widget.prison?.prisonName ?? '',
    );

    prisonLocationController = TextEditingController(
      text: widget.prison?.prisonLocation ?? '',
    );
  }

  @override
  void dispose() {
    prisonIdController.dispose();
    prisonNameController.dispose();
    prisonLocationController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: deepGreen,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: deepGreen,
          width: 1.5,
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: fieldDecoration(label, icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? 20
                : 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: deepGreen,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Prison' : 'Register Prison',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: deepGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const Divider(height: 24),

                buildField(
                  label: 'Prison ID',
                  icon: Icons.badge_outlined,
                  controller: prisonIdController,
                ),

                buildField(
                  label: 'Prison Name',
                  icon: Icons.account_balance_outlined,
                  controller: prisonNameController,
                ),

                buildField(
                  label: 'Prison Location',
                  icon: Icons.location_on_outlined,
                  controller: prisonLocationController,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: deepGreen,
                          side: const BorderSide(
                            color: deepGreen,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          widget.onSave(
                            prisonIdController.text.trim(),
                            prisonNameController.text.trim(),
                            prisonLocationController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Save Changes' : 'Register',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

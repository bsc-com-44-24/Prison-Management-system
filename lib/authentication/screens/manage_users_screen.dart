import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../services/admin_service.dart';

class ManageUsersScreen extends StatefulWidget {
  final List<Map<String, String>> initialUsers;
  final List<String> availablePrisons;

  const ManageUsersScreen({
    super.key,
    this.initialUsers = const [],
    this.availablePrisons = const [],
  });

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManagedUser {
  String id;
  String fullName;
  String username;
  String email;
  String role;
  String? prisonId;
  String prisonName;
  String status;
  List<String> permissions;

  _ManagedUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.role,
    required this.prisonId,
    required this.prisonName,
    required this.status,
    required this.permissions,
  });

  factory _ManagedUser.fromMap(Map<String, dynamic> map) {
    return _ManagedUser(
      id: map['id']?.toString() ?? '',
      fullName:
          map['fullName']?.toString() ??
          map['full_name']?.toString() ??
          map['username']?.toString() ??
          '',
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      prisonId: map['prisonId']?.toString(),
      prisonName: map['prisonName']?.toString() ?? '',
      status: map['status']?.toString() ?? 'ACTIVE',
      permissions: (map['permissions'] as List? ?? const [])
          .map((permission) => permission.toString())
          .toList(),
    );
  }
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color background = Color(0xFFF4F5F3);

  final TextEditingController searchController = TextEditingController();

  List<_ManagedUser> users = [];
  List<Map<String, dynamic>> prisons = [];
  bool isLoading = true;
  String? loadError;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    users = widget.initialUsers
        .map((user) => _ManagedUser.fromMap(user))
        .toList();
    _loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_ManagedUser> get filteredUsers {
    if (searchQuery.trim().isEmpty) return users;

    return users.where((user) {
      final query = searchQuery.toLowerCase();

      return user.username.toLowerCase().contains(query) ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.prisonName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        AdminApiService.getUsers(),
        AdminApiService.getPrisons(),
      ]);
      if (!mounted) return;
      setState(() {
        users = results[0].map(_ManagedUser.fromMap).toList();
        prisons = results[1];
        isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = error.message;
      });
    }
  }

  void showUserForm({_ManagedUser? user}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _UserFormDialog(
          user: user,
          availablePrisons: prisons,
          onSave: (fullName, username, email, password, role, prisonId) async {
            try {
              if (user == null) {
                await AdminApiService.createUser(
                  fullName: fullName,
                  username: username,
                  password: password!,
                  email: email,
                  role: role,
                  prisonId: prisonId,
                );
              } else {
                await AdminApiService.updateUser(
                  id: user.id,
                  fullName: fullName,
                  username: username,
                  email: email,
                  role: role,
                  prisonId: prisonId,
                  permissions: user.permissions,
                );
              }
              if (!mounted || !dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              await _loadUsers();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    user == null
                        ? 'User created successfully'
                        : 'User details updated successfully',
                  ),
                  backgroundColor: deepGreen,
                ),
              );
            } on ApiException catch (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.message)));
            }
          },
        );
      },
    );
  }

  void showUserActions(_ManagedUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  backgroundColor: deepGreen.withValues(alpha: 0.12),
                  child: const Icon(Icons.person, size: 32, color: deepGreen),
                ),
                const SizedBox(height: 10),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: deepGreen,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: deepGreen),
                  title: const Text(
                    'Edit User',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Update user information'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showUserForm(user: user);
                  },
                ),
                ListTile(
                  leading: Icon(
                    user.status.toUpperCase() == 'ACTIVE'
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                    color: maroon,
                  ),
                  title: Text(
                    user.status.toUpperCase() == 'ACTIVE'
                        ? 'Deactivate User'
                        : 'Reactivate User',
                    style: const TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Change account access status'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _changeUserStatus(user);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: deepGreen,
                      side: const BorderSide(color: deepGreen),
                      padding: const EdgeInsets.symmetric(vertical: 13),
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

  Future<void> _changeUserStatus(_ManagedUser user) async {
    final isActive = user.status.toUpperCase() == 'ACTIVE';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: maroon.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.delete_outline,
                  size: 34,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? 'Deactivate User?' : 'Reactivate User?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: isActive ? maroon : deepGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isActive
                    ? 'This will prevent the user from signing in.'
                    : 'This will restore the user account’s access.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 14),
              Text(
                user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: deepGreen,
                        side: const BorderSide(color: deepGreen),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        try {
                          await AdminApiService.setUserActive(
                            id: user.id,
                            active: !isActive,
                          );
                          await _loadUsers();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isActive
                                    ? 'User deactivated.'
                                    : 'User reactivated.',
                              ),
                              backgroundColor: deepGreen,
                            ),
                          );
                        } on ApiException catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? maroon : deepGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(isActive ? 'Deactivate' : 'Reactivate'),
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
    final displayedUsers = filteredUsers;

    return Scaffold(
      backgroundColor: background,
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
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Manage Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search, color: deepGreen),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (users.isNotEmpty)
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
                      const Icon(Icons.groups, color: deepGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Total Users: ${users.length}',
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: deepGreen),
                    )
                  : loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(loadError!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : users.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 85,
                              color: deepGreen,
                            ),
                            SizedBox(height: 18),
                            Text(
                              'No Users Found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: deepGreen,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'There are currently no user accounts registered in the system.',
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
                  : displayedUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching users found',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: displayedUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];

                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showUserActions(user),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: deepGreen.withValues(
                                      alpha: 0.10,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: deepGreen,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          user.role.replaceAll('_', ' '),
                                          style: const TextStyle(
                                            color: deepGreen,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserForm(),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final _ManagedUser? user;
  final List<Map<String, dynamic>> availablePrisons;

  final Future<void> Function(
    String fullName,
    String username,
    String email,
    String? password,
    String role,
    String? prisonId,
  )
  onSave;

  const _UserFormDialog({
    required this.user,
    required this.availablePrisons,
    required this.onSave,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  String? selectedRole;
  String? selectedPrison;
  bool isSaving = false;

  final List<String> roles = [
    'Super Admin',
    'Commissioner',
    'Records Officer',
    'Prison Officer',
    'Duty Officer',
    'Program Facilitator',
  ];

  bool get isEditing => widget.user != null;

  static String _generateTemporaryPassword() {
    const characters =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%&*';
    final random = Random.secure();
    return List.generate(
      16,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
  }

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    emailController = TextEditingController(text: widget.user?.email ?? '');
    passwordController = TextEditingController(
      text: isEditing ? '' : _generateTemporaryPassword(),
    );

    selectedRole = widget.user?.role;
    selectedPrison = widget.user?.prisonId;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: deepGreen, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F8F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: deepGreen, width: 1.5),
      ),
    );
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        obscureText: false,
        validator:
            validator ??
            (value) {
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_add_alt_1,
                      color: deepGreen,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit User' : 'Add User',
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
                  label: 'Full Name',
                  icon: Icons.badge_outlined,
                  controller: fullNameController,
                ),
                buildField(
                  label: 'Username',
                  icon: Icons.person_outline,
                  controller: usernameController,
                ),
                buildField(
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: fieldDecoration(
                      'Select Role',
                      Icons.admin_panel_settings_outlined,
                    ),
                    items: roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a role' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedPrison,
                    decoration: fieldDecoration(
                      'Select Prison',
                      Icons.account_balance_outlined,
                    ),
                    items: [
                      ...widget.availablePrisons.map((prison) {
                        final id = prison['id']?.toString() ?? '';
                        return DropdownMenuItem(
                          value: id,
                          child: Text(prison['name']?.toString() ?? id),
                        );
                      }),
                    ],
                    onChanged: widget.availablePrisons.isEmpty
                        ? null
                        : (value) {
                            setState(() => selectedPrison = value);
                          },
                    hint: Text(
                      widget.availablePrisons.isEmpty
                          ? 'No prisons available'
                          : 'Select Prison',
                    ),
                  ),
                ),
                if (!isEditing)
                  buildField(
                    label: 'Temporary Password',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    readOnly: true,
                  ),
                if (isEditing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Password is not changed when editing user details.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: deepGreen,
                          side: const BorderSide(color: deepGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => isSaving = true);
                                await widget.onSave(
                                  fullNameController.text.trim(),
                                  usernameController.text.trim(),
                                  emailController.text.trim(),
                                  isEditing ? null : passwordController.text,
                                  selectedRole!,
                                  selectedPrison,
                                );
                                if (mounted) setState(() => isSaving = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isSaving
                              ? 'Saving...'
                              : isEditing
                              ? 'Save Changes'
                              : 'Create',
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

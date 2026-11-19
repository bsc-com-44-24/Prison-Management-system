
import 'package:material_ui/material_ui.dart';

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
  String username;
  String email;
  String nationalId;
  String role;
  String prison;

  _ManagedUser({
    required this.username,
    required this.email,
    required this.nationalId,
    required this.role,
    required this.prison,
  });

  factory _ManagedUser.fromMap(Map<String, String> map) {
    return _ManagedUser(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      nationalId: map['nationalId'] ?? '',
      role: map['role'] ?? '',
      prison: map['prison'] ?? '',
    );
  }
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroon = Color(0xFF7A2032);
  static const Color background = Color(0xFFF4F5F3);

  final TextEditingController searchController = TextEditingController();

  late List<_ManagedUser> users;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    users = widget.initialUsers
        .map((user) => _ManagedUser.fromMap(user))
        .toList();
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
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.prison.toLowerCase().contains(query);
    }).toList();
  }

  void showUserForm({_ManagedUser? user}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _UserFormDialog(
          user: user,
          availablePrisons: widget.availablePrisons,
          onSave: (username, email, nationalId, role, prison) {
            setState(() {
              if (user == null) {
                users.add(
                  _ManagedUser(
                    username: username,
                    email: email,
                    nationalId: nationalId,
                    role: role,
                    prison: prison,
                  ),
                );
              } else {
                user.username = username;
                user.email = email;
                user.nationalId = nationalId;
                user.role = role;
                user.prison = prison;
              }
            });

            Navigator.pop(dialogContext);

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
                  backgroundColor: deepGreen.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: deepGreen,
                  ),
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
                  leading: const Icon(
                    Icons.delete_outline,
                    color: maroon,
                  ),
                  title: const Text(
                    'Delete User',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Remove this user account'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showDeleteConfirmation(user);
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

  void showDeleteConfirmation(_ManagedUser user) {
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

              const Text(
                'Delete User?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Are you sure you want to permanently delete this user account?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
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
                      onPressed: () {
                        setState(() {
                          users.remove(user);
                        });

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User deleted successfully'),
                            backgroundColor: deepGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
                      const Icon(
                        Icons.groups,
                        color: deepGreen,
                        size: 20,
                      ),
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
              child: users.isEmpty
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
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
                                        backgroundColor:
                                            deepGreen.withValues(alpha: 0.10),
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
  final List<String> availablePrisons;

  final Function(
    String username,
    String email,
    String nationalId,
    String role,
    String prison,
  ) onSave;

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

  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController nationalIdController;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedRole;
  String? selectedPrison;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final List<String> roles = [
    'COMMISSIONER',
    'PRISON_OFFICER',
    'RECORDS_OFFICER',
    'PROGRAM_FACILITATOR',
  ];

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );
    nationalIdController = TextEditingController(
      text: widget.user?.nationalId ?? '',
    );

    selectedRole = widget.user?.role;
    selectedPrison = widget.user?.prison;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    nationalIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
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
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword
            ? obscurePassword
            : isConfirmPassword
                ? obscureConfirmPassword
                : false,
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
        decoration: fieldDecoration(
          label,
          icon,
          suffix: isPassword || isConfirmPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        obscurePassword = !obscurePassword;
                      } else {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      }
                    });
                  },
                  icon: Icon(
                    (isPassword ? obscurePassword : obscureConfirmPassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
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

                buildField(
                  label: 'National ID',
                  icon: Icons.badge_outlined,
                  controller: nationalIdController,
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
                        child: Text(
                          role.replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 13),
                        ),
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
                    items: widget.availablePrisons.map((prison) {
                      return DropdownMenuItem(
                        value: prison,
                        child: Text(
                          prison,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: widget.availablePrisons.isEmpty
                        ? null
                        : (value) {
                            setState(() => selectedPrison = value);
                          },
                    validator: (value) =>
                        value == null ? 'Please select a prison' : null,
                    hint: Text(
                      widget.availablePrisons.isEmpty
                          ? 'No prisons available'
                          : 'Select Prison',
                    ),
                  ),
                ),

                if (!isEditing)
                  buildField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Password must have at least 8 characters';
                      }
                      return null;
                    },
                  ),

                if (!isEditing)
                  buildField(
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    controller: confirmPasswordController,
                    isConfirmPassword: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                if (isEditing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Password is not changed when editing user details.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          widget.onSave(
                            usernameController.text.trim(),
                            emailController.text.trim(),
                            nationalIdController.text.trim(),
                            selectedRole!,
                            selectedPrison!,
                          );
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
                          isEditing ? 'Save Changes' : 'Create',
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

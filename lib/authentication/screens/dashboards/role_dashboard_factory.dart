import 'package:material_ui/material_ui.dart';

import 'commissioner_dash_screen.dart';
import 'prison_officer_dash.dart';
import 'program_facilitator_dash.dart';
import 'records_officer_dash.dart';
import 'system_admin_dashboard.dart';

class RoleDashboardFactory {
  static String normalizeRole(Object? value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ');
  }

  static Widget build(Map<String, Object?> user) {
    switch (normalizeRole(user['role'])) {
      case 'admin':
      case 'super admin':
      case 'system admin':
      case 'system administrator':
        return DashboardScreen(user: user);
      case 'commissioner':
      case 'prison commissioner':
        return CommissionerDashboardScreen(user: user);
      case 'prison officer':
      case 'duty officer':
        return PrisonOfficerDashboardScreen(user: user);
      case 'record officer':
      case 'records officer':
        return RecordsOfficerDashboardScreen(user: user);
      case 'program facilitator':
        return ProgramFacilitatorDashboardScreen(user: user);
      default:
        throw ArgumentError('Unsupported account role: ${user['role']}');
    }
  }
}

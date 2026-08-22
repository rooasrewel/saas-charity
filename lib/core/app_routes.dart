import 'package:flutter/material.dart';

import 'package:saas/features/delegate/presentation/pages/delegate_setup_page.dart';
import 'package:saas/features/delegate/presentation/pages/pending_approval_page.dart';
import 'package:saas/features/delegate/presentation/pages/delegate_dashboard.dart';
import 'package:saas/features/delegate/presentation/pages/settings_page.dart';
import 'package:saas/features/delegate/presentation/pages/profile_page.dart';

import '../features/delegate/presentation/pages/field_audit_page.dart';
import '../features/delegate/presentation/pages/message_page.dart';

class AppRoutes {
  static const String setup = '/setup';
  static const String pending = '/pending';
  static const String dashboard = '/dashboard';
  static const String fieldAudit = '/fieldAudit';
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
    // ========================================
    // SETUP
    // ========================================
      case setup:
        return MaterialPageRoute(
          builder: (_) => const DelegateSetupPage(),
        );

    // ========================================
    // PENDING
    // ========================================
      case pending:
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalPage(),
        );

    // ========================================
    // DASHBOARD
    // ========================================
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DelegateDashboard(),
        );

    // ========================================
    // FIELD AUDIT
    // ========================================
      case fieldAudit:
        final int caseId = (routeSettings.arguments is int)
            ? routeSettings.arguments as int
            : int.tryParse(routeSettings.arguments?.toString() ?? '0') ?? 0;

        return MaterialPageRoute(
          builder: (_) => FieldAuditPage(caseId: caseId),
        );

    // ========================================
    // MESSAGES
    // ========================================
      case messages:
        return MaterialPageRoute(
          builder: (_) => const MessagesPage(),
        );

    // ========================================
    // SETTINGS
    // ========================================
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(userRole: 'delegate'),
        );

    // ========================================
    // PROFILE
    // ========================================
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );

    // ========================================
    // DEFAULT
    // ========================================
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Page not found"),
            ),
          ),
        );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/public/public_screen.dart';
import '../../screens/official/official_hub_screen.dart';
import '../../screens/admin/admin_console_screen.dart';
import '../../screens/collection/fee_collection_screen.dart';
import '../../screens/worksheet/worksheet_screen.dart';
import '../../screens/results/result_management_screen.dart';
import '../../screens/student/student_portal_screen.dart';
import '../widgets/app_button.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class AppRouter {
  // Named Route Constants
  static const String home = '/';
  static const String public = '/';
  static const String hub = '/hub';
  static const String admin = '/admin';
  static const String collection = '/collection';
  static const String worksheet = '/worksheet';
  static const String results = '/results';
  static const String student = '/student';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined, size: 60, color: AppColors.slate400),
              const SizedBox(height: 16),
              Text('404 - Page Not Found', style: AppTypography.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'The route "${state.uri.path}" could not be located.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Return to Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go(home),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const PublicScreen(),
      ),
      GoRoute(
        path: hub,
        builder: (context, state) => const OfficialHubScreen(),
      ),
      GoRoute(
        path: admin,
        builder: (context, state) => const AdminConsoleScreen(),
      ),
      GoRoute(
        path: collection,
        builder: (context, state) => const FeeCollectionScreen(),
      ),
      GoRoute(
        path: worksheet,
        builder: (context, state) => const WorksheetScreen(),
      ),
      GoRoute(
        path: results,
        builder: (context, state) => const ResultManagementScreen(),
      ),
      GoRoute(
        path: student,
        builder: (context, state) => const StudentPortalScreen(),
      ),
    ],
  );
}

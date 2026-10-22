import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/institution_provider.dart';
import '../../core/routing/app_router.dart';
import '../collection/fee_collection_screen.dart';
import '../worksheet/worksheet_screen.dart';
import '../results/result_management_screen.dart';
import '../admin/admin_console_screen.dart';

class OfficialHubScreen extends StatelessWidget {
  const OfficialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final staff = provider.currentStaff;
    final staffName = staff?.name ?? 'Official Staff';
    final staffRole = staff?.role ?? 'FACULTY';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Staff Hub',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              '$staffName • $staffRole',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout Session',
            onPressed: () {
              provider.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : 'S',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $staffName!',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Authorized modules for your role are accessible below.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'MANAGEMENT MODULES (THE 4 PORTALS)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),

            // 4 Portals Grid
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: constraints.maxWidth > 700 ? 2.4 : 2.0,
                  children: [
                    _buildModuleTile(
                      context,
                      title: 'Fee Collection & Accounting',
                      description: 'Fee entry, instant thermal & PDF receipts, master ledger, and transaction history.',
                      icon: Icons.receipt_long,
                      color: Colors.teal,
                      hasAccess: staff?.hasCollectionAccess ?? true,
                      onTap: () => context.push(AppRouter.collection),
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Result Management System',
                      description: 'Marks entry, live grades calculation, progress report cards, and publication controls.',
                      icon: Icons.grade,
                      color: Colors.indigo,
                      hasAccess: staff?.hasResultAccess ?? true,
                      onTap: () => context.push(AppRouter.results),
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Class Worksheet & Registers',
                      description: 'Class summary, student directory, alumni register, spreadsheet builder, and print canvas.',
                      icon: Icons.table_chart,
                      color: Colors.amber.shade800,
                      hasAccess: staff?.hasWorksheetAccess ?? true,
                      onTap: () => context.push(AppRouter.worksheet),
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Admin Command Center',
                      description: 'Institution settings, classes, zero-gap continuity, fee rules, and staff permissions.',
                      icon: Icons.admin_panel_settings,
                      color: Colors.red,
                      hasAccess: staff?.hasAdminAccess ?? true,
                      onTap: () => context.push(AppRouter.admin),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool hasAccess,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: hasAccess
            ? onTap
            : () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Access Restricted'),
                    content: const Text(
                      'Your staff account does not have permission to access this module. Please contact the administrator.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                    ],
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        if (!hasAccess)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('LOCKED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

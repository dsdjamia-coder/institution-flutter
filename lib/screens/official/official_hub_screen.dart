import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/institution_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class OfficialHubScreen extends StatelessWidget {
  const OfficialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final staff = provider.currentStaff;
    final staffName = staff?.name ?? 'Official Staff';
    final staffRole = staff?.role ?? 'FACULTY';
    final setting = provider.setting;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Row(
              children: [
                // Application Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 20, color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.institutionName.isNotEmpty ? setting.institutionName : 'Institution Workspace',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Text(
                      'Executive Staff & Faculty Command Hub',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Staff Identity Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        staffName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          staffRole,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                  tooltip: 'Sign Out Session',
                  onPressed: () => _confirmLogout(context, provider),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive Welcome Banner
                _buildWelcomeBanner(context, staffName, staffRole),
                const SizedBox(height: 24),

                // Live KPI Ribbon
                _buildKpiRibbon(context, provider, isDesktop),
                const SizedBox(height: 28),

                // Section Title
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MANAGEMENT MODULES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '4 Active Workspaces',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4 Management Modules Grid
                _buildModulesGrid(context, staff, isDesktop),
                const SizedBox(height: 32),

                // System Trust & Connectivity Bar
                _buildSystemTrustBar(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String staffName, String staffRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : 'S',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back, $staffName',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 10, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'Active Session',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: $staffRole • Authorized modules for your security profile are unlocked below.',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRibbon(BuildContext context, InstitutionProvider provider, bool isDesktop) {
    final currencySymbol = provider.setting.currencySymbol;
    final totalStudents = provider.students.length;
    final totalStaff = provider.staffList.length;
    final activeYear = provider.setting.activeAcademicYear;
    final todayCollection = provider.todayCollection;

    final cards = [
      _buildKpiCard(
        title: 'TOTAL STUDENTS',
        value: totalStudents.toString(),
        subtitle: 'Enrolled across all classes',
        icon: Icons.groups_rounded,
        accentColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _buildKpiCard(
        title: 'FACULTY & STAFF',
        value: totalStaff.toString(),
        subtitle: 'Registered official accounts',
        icon: Icons.badge_rounded,
        accentColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
      ),
      _buildKpiCard(
        title: 'ACADEMIC SESSION',
        value: activeYear,
        subtitle: 'Zero-gap continuity enabled',
        icon: Icons.calendar_today_rounded,
        accentColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
      ),
      _buildKpiCard(
        title: "TODAY'S COLLECTION",
        value: '$currencySymbol${todayCollection.toStringAsFixed(0)}',
        subtitle: 'Recorded in current session',
        icon: Icons.payments_rounded,
        accentColor: const Color(0xFF059669),
        bgColor: const Color(0xFFD1FAE5),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                ))
            .toList(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: cards,
      );
    }
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, dynamic staff, bool isDesktop) {
    final modules = [
      _ModuleData(
        title: 'Fee Collection & Accounting',
        description: 'Comprehensive fee counter, compound student search, instant thermal & PDF receipts, master ledger, and payment VOID controls.',
        icon: Icons.receipt_long_rounded,
        accentColor: const Color(0xFF059669),
        accentBg: const Color(0xFFECFDF5),
        borderHighlight: const Color(0xFFA7F3D0),
        route: AppRouter.collection,
        hasAccess: staff?.hasCollectionAccess ?? true,
        tags: ['Point of Sale', 'Receipt Reprint', 'Master Ledger'],
      ),
      _ModuleData(
        title: 'Result Management System',
        description: 'Cohort marks entry, automated grades calculation, progress report card generation, student portal publishing, and annual promotion.',
        icon: Icons.grade_rounded,
        accentColor: const Color(0xFF4F46E5),
        accentBg: const Color(0xFFEEF2FF),
        borderHighlight: const Color(0xFFC7D2FE),
        route: AppRouter.results,
        hasAccess: staff?.hasResultAccess ?? true,
        tags: ['Marks Entry', 'Grade Auto-Calc', 'Promotion Engine'],
      ),
      _ModuleData(
        title: 'Class Worksheet & Registers',
        description: 'Demographic class summaries, student register, permanent alumni graduated cohorts archive, faculty directory, and Excel canvas.',
        icon: Icons.table_chart_rounded,
        accentColor: const Color(0xFFD97706),
        accentBg: const Color(0xFFFFFBEB),
        borderHighlight: const Color(0xFFFDE68A),
        route: AppRouter.worksheet,
        hasAccess: staff?.hasWorksheetAccess ?? true,
        tags: ['Class Demographics', 'Alumni Register', 'Excel Canvas'],
      ),
      _ModuleData(
        title: 'Admin Command Center',
        description: 'Institution identity, zero-gap class & division architecture, fee structures, student admissions, staff privileges, and audit logs.',
        icon: Icons.admin_panel_settings_rounded,
        accentColor: const Color(0xFFE11D48),
        accentBg: const Color(0xFFFFF1F2),
        borderHighlight: const Color(0xFFFECDD3),
        route: AppRouter.admin,
        hasAccess: staff?.hasAdminAccess ?? true,
        tags: ['Class Architecture', 'Fee Settings', 'Staff Roles'],
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final crossAxisCount = constraints.maxWidth >= 768 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 2 ? 1.85 : 1.5,
          ),
          itemBuilder: (ctx, idx) => _buildModuleCard(context, modules[idx]),
        );
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleData module) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: module.hasAccess ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (module.hasAccess) {
              context.push(module.route);
            } else {
              _showAccessRestrictedDialog(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: module.accentBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: module.borderHighlight),
                      ),
                      child: Icon(module.icon, color: module.accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  module.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: module.hasAccess ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: module.hasAccess ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  module.hasAccess ? 'AUTHORIZED' : 'LOCKED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: module.hasAccess ? const Color(0xFF059669) : const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            module.description,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: module.tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: module.hasAccess ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            module.hasAccess ? 'Open' : 'Restricted',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: module.hasAccess ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            module.hasAccess ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
                            size: 14,
                            color: module.hasAccess ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                          ),
                        ],
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

  Widget _buildSystemTrustBar(InstitutionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF059669), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected to Cloud Database (Firestore)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Database: institution-db743 • Institute: TEST_INSTITUTE_01 • SSL/TLS 256-bit encrypted',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE SYNC',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669), letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, InstitutionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your current staff session and return to the public landing page?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.logout();
              context.go(AppRouter.public);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAccessRestrictedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 10),
            Text('Access Restricted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Your staff profile does not have permission to access this module. Please contact the administrator to update your authorization privileges.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ModuleData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final Color borderHighlight;
  final String route;
  final bool hasAccess;
  final List<String> tags;

  _ModuleData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.borderHighlight,
    required this.route,
    required this.hasAccess,
    required this.tags,
  });
}

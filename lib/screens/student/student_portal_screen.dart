import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/institution_provider.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen({super.key});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final student = provider.currentStudent;
    final setting = provider.setting;
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Portal')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 56, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 16),
              const Text(
                'No active student session detected.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please sign in with your Admission Number from the landing page.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.public),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Return to Landing Page'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final studentPayments = provider.payments
        .where((p) => (p.studentId == student.id || p.admissionNo == student.adm) && p.status == 'VALID')
        .toList();
    final studentResults = provider.examResults
        .where((r) => (r.studentId == student.id || r.admissionNo == student.adm) && r.published)
        .toList();

    return AdaptivePortalScaffold(
      portalId: 'student',
      portalTitle: 'Student & Parent Portal',
      portalSubtitle: 'Digital ID, fee receipts, published marks, and official notices',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      headerActions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          tooltip: 'Sign Out Session',
          onPressed: () {
            provider.logout();
            context.go(AppRouter.public);
          },
        ),
      ],
      tabs: [
        // TAB 1: DIGITAL ID CARD
        PortalTabItem(
          id: 'id_card',
          label: 'Digital ID Card',
          icon: Icons.badge_rounded,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Center(
              child: _buildDigitalIdCard(context, student, setting),
            ),
          ),
        ),

        // TAB 2: FEE RECEIPTS
        PortalTabItem(
          id: 'receipts',
          label: 'Fee Receipts',
          icon: Icons.receipt_long_rounded,
          body: _buildFeeReceiptsTab(context, studentPayments, setting),
        ),

        // TAB 3: EXAM RESULTS
        PortalTabItem(
          id: 'results',
          label: 'Exam Results',
          icon: Icons.grade_rounded,
          body: _buildExamResultsTab(studentResults),
        ),

        // TAB 4: NOTICES
        PortalTabItem(
          id: 'notices',
          label: 'Notices',
          icon: Icons.notifications_active_rounded,
          body: _buildNoticesTab(provider),
        ),
      ],
    );
  }

  // ==================== TAB 1: DIGITAL ID CARD ====================
  Widget _buildDigitalIdCard(BuildContext context, dynamic student, dynamic setting) {
    final isAlumni = student.status == 'Alumni';

    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAlumni
              ? [const Color(0xFF581C87), const Color(0xFF3B0764)]
              : [const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isAlumni ? const Color(0xFF581C87) : const Color(0xFF1E3A8A)).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo + Institution Name + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 18, color: Color(0xFF2563EB)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.institutionName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Text(
                        'OFFICIAL STUDENT IDENTITY CARD',
                        style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  isAlumni ? 'GRADUATED ALUMNI' : 'ACTIVE STUDENT',
                  style: TextStyle(
                    color: isAlumni ? const Color(0xFFFDE047) : Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),

          // Body: Avatar + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildIdField('Admission #', '#${student.adm}', isMonospace: true),
                    if (isAlumni)
                      _buildIdField(
                        'Graduated Batch',
                        student.graduatedYear.isNotEmpty ? student.graduatedYear : student.academicYear,
                        highlightColor: const Color(0xFFFDE047),
                      )
                    else ...[
                      _buildIdField('Class Cohort', student.studentClass),
                      if (student.roll.isNotEmpty) _buildIdField('Roll Number', student.roll),
                    ],
                    if (student.father.isNotEmpty) _buildIdField('Guardian / Father', student.father),
                    if (student.mobile.isNotEmpty) _buildIdField('Contact Number', student.mobile),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bottom Bar: Simulated Barcode & Security Stamp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: Colors.white70, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${student.id.length > 12 ? student.id.substring(0, 12).toUpperCase() : student.id.toUpperCase()}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Digitally Verified Record',
                          style: TextStyle(color: Colors.white38, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digital Student ID ready to print or save.')),
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 14, color: Colors.white),
                  label: const Text('Print Card', style: TextStyle(color: Colors.white, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdField(String label, String value, {bool isMonospace = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlightColor ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: FEE RECEIPTS ====================
  Widget _buildFeeReceiptsTab(BuildContext context, List<dynamic> payments, dynamic setting) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text('No fee receipts recorded on this account yet.', style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final p = payments[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppColors.cardShadow,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_rounded, color: Color(0xFF059669), size: 20),
            ),
            title: Row(
              children: [
                Text(
                  'Receipt #${p.receiptNo}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    p.paymentMode,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${p.paymentDate} • ${p.feeItems.map((e) => e.itemLabel).join(", ")}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF059669),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.print_rounded, size: 20, color: Color(0xFF2563EB)),
                  tooltip: 'Reprint / Download Receipt',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReceiptDialog(payment: p, setting: setting),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== TAB 3: EXAM RESULTS ====================
  Widget _buildExamResultsTab(List<dynamic> results) {
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text('No published examination results available yet.', style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final r = results[idx];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r.examId.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: -0.2),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Text(
                      'Grade: ${r.grade}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB), fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Marks Scored', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          '${r.total.toStringAsFixed(0)} Marks',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Percentage', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          '${r.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
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

  // ==================== TAB 4: NOTICES ====================
  Widget _buildNoticesTab(InstitutionProvider provider) {
    if (provider.notices.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.campaign_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Session Communication',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Official announcements regarding timetables, holidays, and examination schedules will be published directly here by the administration.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: provider.notices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final n = provider.notices[idx];
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(n.headline, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(n.date, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 6),
              Text(n.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
            ],
          ),
        );
      },
    );
  }
}

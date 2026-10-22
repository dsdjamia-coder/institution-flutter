import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';

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

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Portal')),
        body: const Center(child: Text('No active student session. Please login.')),
      );
    }

    final studentPayments = provider.payments
        .where((p) => p.studentId == student.id || p.admissionNo == student.adm)
        .toList();
    final studentResults = provider.examResults
        .where((r) => (r.studentId == student.id || r.admissionNo == student.adm) && r.published)
        .toList();

    return AdaptivePortalScaffold(
      portalTitle: 'Student & Alumni Portal',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      headerActions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          tooltip: 'Logout',
          onPressed: () {
            provider.logout();
            Navigator.pop(context);
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
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.indigo.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade900.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 14, color: Color(0xFF2563EB)),
                              ),
                            ),
                            Text(
                              setting.institutionName.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            student.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                            style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text('Adm #: ${student.adm}', style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontFamily: 'monospace')),
                              if (student.status == 'Alumni')
                                Text(
                                  'Graduated Batch: ${student.graduatedYear.isNotEmpty ? student.graduatedYear : student.academicYear}',
                                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12.5, fontWeight: FontWeight.bold),
                                )
                              else
                                Text('Class: ${student.studentClass} • Roll: ${student.roll}', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                              if (student.father.isNotEmpty)
                                Text('Guardian: ${student.father}', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                              if (student.mobile.isNotEmpty)
                                Text('Contact: ${student.mobile}', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
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
        ),

        // TAB 2: FEE RECEIPTS
        PortalTabItem(
          id: 'receipts',
          label: 'Fee Receipts',
          icon: Icons.receipt_long_rounded,
          body: studentPayments.isEmpty
              ? const Center(child: Text('No fee payment records found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: studentPayments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final p = studentPayments[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.receipt, color: Colors.teal.shade700),
                        ),
                        title: Text('Receipt #${p.receiptNo} • ${p.paymentMode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${p.paymentDate} • ${p.feeItems.map((e) => e.itemLabel).join(', ')}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18, color: Colors.blue),
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
                ),
        ),

        // TAB 3: EXAM RESULTS
        PortalTabItem(
          id: 'results',
          label: 'Exam Results',
          icon: Icons.grade_rounded,
          body: studentResults.isEmpty
              ? const Center(child: Text('No published exam results available yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: studentResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final r = studentResults[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Exam: ${r.examId.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text('Grade: ${r.grade}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text('Total Marks: ${r.total.toStringAsFixed(0)} (${r.percentage.toStringAsFixed(1)}%)'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // TAB 4: NOTICES
        PortalTabItem(
          id: 'notices',
          label: 'Notices',
          icon: Icons.notifications_active_rounded,
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const ListTile(
                  leading: Icon(Icons.campaign, color: Colors.blue),
                  title: Text('Academic Session Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Classes, timings, and examination schedules will be notified here directly by the administration.'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

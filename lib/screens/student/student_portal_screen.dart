import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../widgets/receipt_dialog.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen({super.key});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

    final studentPayments = provider.payments.where((p) => p.studentId == student.id || p.admissionNo == student.adm).toList();
    final studentResults = provider.examResults.where((r) => (r.studentId == student.id || r.admissionNo == student.adm) && r.published).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text('Class: ${student.studentClass} • Adm: #${student.adm}', style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () {
              provider.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digital ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        setting.institutionName.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text('Adm #: ${student.adm}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                            Text('Class: ${student.studentClass} • Roll: ${student.roll}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            if (student.father.isNotEmpty)
                              Text('Guardian: ${student.father}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            if (student.mobile.isNotEmpty)
                              Text('Contact: ${student.mobile}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tabs for Portal Features
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.blue.shade700,
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_long, size: 18), text: 'Fee Receipts'),
                  Tab(icon: Icon(Icons.grade, size: 18), text: 'Exam Results'),
                  Tab(icon: Icon(Icons.notifications_active, size: 18), text: 'Notices'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Fee Receipts
                  studentPayments.isEmpty
                      ? const Center(child: Text('No fee payment records found.'))
                      : ListView.separated(
                          itemCount: studentPayments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final p = studentPayments[idx];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.emerald.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.receipt, color: Colors.emerald.shade700),
                                ),
                                title: Text('Receipt #${p.receiptNo} • ${p.paymentMode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('${p.paymentDate} • ${p.feeItems.map((e) => e.itemLabel).join(', ')}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.emerald.shade800),
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

                  // Tab 2: Exam Results
                  studentResults.isEmpty
                      ? const Center(child: Text('No published exam results available yet.'))
                      : ListView.separated(
                          itemCount: studentResults.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final r = studentResults[idx];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
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

                  // Tab 3: Notices
                  ListView(
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: const ListTile(
                          leading: Icon(Icons.campaign, color: Colors.blue),
                          title: Text('Academic Session Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Classes and exam schedules will be notified here directly by the administration.'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

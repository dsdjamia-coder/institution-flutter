import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../models/payment.dart';
import '../../widgets/compound_student_search.dart';
import '../../widgets/receipt_dialog.dart';

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected Student
  Student? _selectedStudent;
  String _selectedClass = 'ALL';
  String _selectedPeriod = 'June-2026';
  String _paymentMode = 'CASH';

  // Fee Items
  final List<Map<String, dynamic>> _feeCatalog = [
    {'key': 'tuition', 'label': 'Monthly Tuition Fee', 'amount': 350.0, 'selected': true},
    {'key': 'bus', 'label': 'Transportation / Bus Fund', 'amount': 400.0, 'selected': false},
    {'key': 'books', 'label': 'Curriculum Books & Stationery', 'amount': 600.0, 'selected': false},
    {'key': 'exam', 'label': 'Examination & Lab Fee', 'amount': 250.0, 'selected': false},
    {'key': 'special', 'label': 'Annual Development Fund', 'amount': 500.0, 'selected': false},
  ];

  bool _isSubmitting = false;

  final List<String> _months = [
    'June-2026', 'July-2026', 'August-2026', 'September-2026',
    'October-2026', 'November-2026', 'December-2026', 'January-2027',
    'February-2027', 'March-2027'
  ];

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

  double get _calculatedTotal {
    double total = 0;
    for (final item in _feeCatalog) {
      if (item['selected'] == true) {
        total += (item['amount'] as double);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Fee Collection Counter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale, size: 18), text: 'Fee Entry'),
            Tab(icon: Icon(Icons.table_view, size: 18), text: 'Master Ledger'),
            Tab(icon: Icon(Icons.history, size: 18), text: 'History & VOID'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: FEE ENTRY
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metrics
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade600]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TODAY'S COLLECTION", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${setting.currencySymbol}${provider.todayCollection.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade600]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("THIS MONTH'S TOTAL", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${setting.currencySymbol}${provider.thisMonthCollection.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. SELECT STUDENT (COMPOUND IDENTITY)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _selectedClass,
                              decoration: InputDecoration(
                                labelText: 'Class',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'ALL', child: Text('All Classes')),
                                ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedClass = val ?? 'ALL';
                                  _selectedStudent = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CompoundStudentSearch(
                              students: provider.students,
                              selectedClass: _selectedClass,
                              selectedStudent: _selectedStudent,
                              hintText: 'Type Name or Adm No...',
                              onStudentSelected: (s) => setState(() => _selectedStudent = s),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Selected Student Banner
                      if (_selectedStudent != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Selected: ${_selectedStudent!.name} (Adm: #${_selectedStudent!.adm}, Class: ${_selectedStudent!.studentClass})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      const Text(
                        '2. FEE PERIOD & ITEMS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: InputDecoration(
                          labelText: 'Select Billing Period / Month',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setState(() => _selectedPeriod = val ?? _months.first),
                      ),
                      const SizedBox(height: 14),

                      // Items Checklist
                      ..._feeCatalog.map((item) {
                        final isPaid = _selectedStudent != null &&
                            provider.payments.any((p) =>
                                p.studentId == _selectedStudent!.id &&
                                p.status == 'VALID' &&
                                p.feeItems.any((fi) => fi.itemKey == item['key'] && fi.period == _selectedPeriod));

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(item['label']),
                              const Spacer(),
                              if (isPaid)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.teal.shade200),
                                  ),
                                  child: const Text('ALREADY PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                                )
                              else
                                Text(
                                  '${setting.currencySymbol}${item['amount']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          value: isPaid ? false : item['selected'],
                          onChanged: isPaid
                              ? null
                              : (val) {
                                  setState(() => item['selected'] = val ?? false);
                                },
                        );
                      }),
                      const Divider(height: 24),

                      // Payment Mode & Submit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: _paymentMode,
                            items: const [
                              DropdownMenuItem(value: 'CASH', child: Text('💵 Cash')),
                              DropdownMenuItem(value: 'UPI', child: Text('📱 UPI / QR')),
                              DropdownMenuItem(value: 'BANK', child: Text('🏦 Bank Transfer')),
                            ],
                            onChanged: (val) => setState(() => _paymentMode = val ?? 'CASH'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL PAYABLE:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(
                            '${setting.currencySymbol}${_calculatedTotal.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleCollectFee,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.print, size: 18),
                        label: Text(_isSubmitting ? 'Recording Payment...' : 'Collect Fee & Issue Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: MASTER LEDGER
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Adm #', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Receipts', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: provider.students.map((st) {
                final stPayments = provider.payments.where((p) => (p.studentId == st.id || p.admissionNo == st.adm) && p.status == 'VALID');
                final totalPaid = stPayments.fold(0.0, (acc, curr) => acc + curr.amount);

                return DataRow(
                  cells: [
                    DataCell(Text(st.adm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                    DataCell(Text(st.name)),
                    DataCell(Text(st.studentClass)),
                    DataCell(Text('${setting.currencySymbol}${totalPaid.toStringAsFixed(0)}')),
                    DataCell(Text(stPayments.length.toString())),
                  ],
                );
              }).toList(),
            ),
          ),

          // TAB 3: HISTORY & VOID
          provider.payments.isEmpty
              ? const Center(child: Text('No payment history recorded yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final p = provider.payments[idx];
                    final isVoided = p.status == 'VOIDED';

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isVoided ? Colors.red.shade200 : Colors.grey.shade200),
                      ),
                      color: isVoided ? Colors.red.shade50.withOpacity(0.4) : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isVoided ? Colors.red.shade100 : Colors.blue.shade50,
                          child: Icon(
                            isVoided ? Icons.cancel : Icons.receipt,
                            color: isVoided ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text('Receipt #${p.receiptNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            if (isVoided)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                child: const Text('VOIDED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        subtitle: Text('${p.studentName} (${p.studentClass}) • ${p.paymentDate} • ${p.paymentMode}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isVoided ? Colors.grey : Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.print, size: 18),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ReceiptDialog(payment: p, setting: setting),
                                );
                              },
                            ),
                            if (!isVoided)
                              IconButton(
                                icon: const Icon(Icons.block, size: 18, color: Colors.red),
                                tooltip: 'Void Receipt',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirm Void'),
                                      content: Text('Are you sure you want to void Receipt #${p.receiptNo}?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                          child: const Text('Void'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    provider.voidPayment(p.id);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _handleCollectFee() async {
    final provider = context.read<InstitutionProvider>();
    final setting = provider.setting;

    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a student first!')));
      return;
    }

    final selectedItems = _feeCatalog.where((i) => i['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one fee item!')));
      return;
    }

    setState(() => _isSubmitting = true);

    final feeEntries = selectedItems.map((i) {
      final key = i['key'] as String;
      final amt = i['amount'] as double;
      return FeeItemEntry(
        itemKey: key,
        itemLabel: i['label'] as String,
        amount: amt,
        period: _selectedPeriod,
        ledgerKey: '${_selectedStudent!.id}_${setting.activeAcademicYear}_${key}_$_selectedPeriod',
      );
    }).toList();

    final payment = Payment(
      id: '',
      paymentId: '',
      receiptNo: provider.nextReceiptNo,
      studentId: _selectedStudent!.id,
      admissionNo: _selectedStudent!.adm,
      studentName: _selectedStudent!.name,
      studentClass: _selectedStudent!.studentClass,
      academicYear: setting.activeAcademicYear,
      amount: _calculatedTotal,
      paymentDate: DateTime.now().toString().split(' ')[0],
      paymentMode: _paymentMode,
      feeItems: feeEntries,
      collectedByName: provider.currentStaff?.name ?? 'Admin Desk',
    );

    final error = await provider.collectPayment(payment);
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      showDialog(
        context: context,
        builder: (_) => ReceiptDialog(payment: payment, setting: setting),
      );
    }
  }
}

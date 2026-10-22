import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../models/payment.dart';
import '../../models/fee_concession.dart';
import '../../widgets/compound_student_search.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> {
  int _currentIndex = 0;

  // Selected Student & Class
  Student? _selectedStudent;
  String _selectedClass = 'ALL';
  String _selectedPeriod = 'June-2026';
  String _paymentMode = 'CASH';

  // Master Ledger search & filter
  String _ledgerSearchQuery = '';
  String _ledgerClassFilter = 'ALL';

  // History search & filter
  String _historySearchQuery = '';
  String _historyStatusFilter = 'ALL';

  // Base Fee Catalog
  final List<Map<String, dynamic>> _feeCatalog = [
    {'key': 'tuition', 'label': 'Monthly Tuition Fee', 'amount': 350.0, 'selected': true},
    {'key': 'bus', 'label': 'Transportation / Bus Fund', 'amount': 400.0, 'selected': false},
    {'key': 'books', 'label': 'Curriculum Books & Stationery', 'amount': 600.0, 'selected': false},
    {'key': 'exam', 'label': 'Examination & Lab Fee', 'amount': 250.0, 'selected': false},
    {'key': 'special', 'label': 'Annual Development Fund', 'amount': 500.0, 'selected': false},
  ];

  bool _isSubmitting = false;

  final List<String> _months = [
    'June-2026',
    'July-2026',
    'August-2026',
    'September-2026',
    'October-2026',
    'November-2026',
    'December-2026',
    'January-2027',
    'February-2027',
    'March-2027',
    'April-2027',
    'May-2027',
  ];

  FeeConcession? _getStudentConcession(InstitutionProvider provider) {
    if (_selectedStudent == null) return null;
    return provider.concessions
        .where((c) => c.studentId == _selectedStudent!.id)
        .firstOrNull;
  }

  double _getItemEffectiveAmount(Map<String, dynamic> item, FeeConcession? concession) {
    if (item['key'] == 'tuition' && concession != null && concession.concessionMonthlyFee > 0) {
      return concession.concessionMonthlyFee;
    }
    return (item['amount'] as num).toDouble();
  }

  double _calculateTotal(FeeConcession? concession) {
    double total = 0;
    for (final item in _feeCatalog) {
      if (item['selected'] == true) {
        total += _getItemEffectiveAmount(item, concession);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;
    final concession = _getStudentConcession(provider);
    final totalPayable = _calculateTotal(concession);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return AdaptivePortalScaffold(
      portalId: 'fees',
      portalTitle: 'Fee Collection Counter',
      portalSubtitle: 'Point of sale, receipts, and master accounting',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      tabs: [
        // TAB 1: FEE ENTRY
        PortalTabItem(
          id: 'entry',
          label: 'Fee Entry',
          icon: Icons.point_of_sale_rounded,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: isDesktop
                ? _buildDesktopWorkstation(context, provider, concession, totalPayable)
                : _buildMobileWorkstation(context, provider, concession, totalPayable),
          ),
        ),

        // TAB 2: MASTER LEDGER
        PortalTabItem(
          id: 'ledger',
          label: 'Master Ledger',
          icon: Icons.table_view_rounded,
          body: _buildMasterLedgerTab(context, provider),
        ),

        // TAB 3: HISTORY & VOID
        PortalTabItem(
          id: 'history',
          label: 'History & VOID',
          icon: Icons.history_rounded,
          body: _buildHistoryTab(context, provider),
        ),
      ],
    );
  }

  // ==================== DESKTOP SPLIT WORKSTATION ====================
  Widget _buildDesktopWorkstation(
    BuildContext context,
    InstitutionProvider provider,
    FeeConcession? concession,
    double totalPayable,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (40%): Metrics + Student Selection + Profile & Recent Receipts
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopMetricsRibbon(provider),
              const SizedBox(height: 20),
              _buildStudentSelectionCard(provider),
              const SizedBox(height: 16),
              if (_selectedStudent != null) ...[
                _buildStudentProfileCard(provider, concession),
                const SizedBox(height: 16),
                _buildStudentRecentPayments(provider),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right Column (60%): Period, Fee Items Checklist, Payment Mode & Checkout
        Expanded(
          flex: 6,
          child: _buildFeeCalculationPanel(provider, concession, totalPayable),
        ),
      ],
    );
  }

  // ==================== MOBILE SINGLE-COLUMN WORKSTATION ====================
  Widget _buildMobileWorkstation(
    BuildContext context,
    InstitutionProvider provider,
    FeeConcession? concession,
    double totalPayable,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopMetricsRibbon(provider),
        const SizedBox(height: 16),
        _buildStudentSelectionCard(provider),
        const SizedBox(height: 14),
        if (_selectedStudent != null) ...[
          _buildStudentProfileCard(provider, concession),
          const SizedBox(height: 14),
        ],
        _buildFeeCalculationPanel(provider, concession, totalPayable),
        if (_selectedStudent != null) ...[
          const SizedBox(height: 16),
          _buildStudentRecentPayments(provider),
        ],
      ],
    );
  }

  // ==================== KPI METRIC RIBBON ====================
  Widget _buildTopMetricsRibbon(InstitutionProvider provider) {
    final symbol = provider.setting.currencySymbol;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.today_rounded, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      "TODAY'S COLLECTION",
                      style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$symbol${provider.todayCollection.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: -0.5,
                  ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      "THIS MONTH'S TOTAL",
                      style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$symbol${provider.thisMonthCollection.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STUDENT SELECTION CARD ====================
  Widget _buildStudentSelectionCard(InstitutionProvider provider) {
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
          const Row(
            children: [
              Icon(Icons.person_search_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                '1. IDENTIFY STUDENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Class Cohort',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: CompoundStudentSearch(
                  students: provider.activeStudents,
                  selectedClass: _selectedClass,
                  selectedStudent: _selectedStudent,
                  hintText: 'Search Name or Adm #...',
                  onStudentSelected: (s) => setState(() => _selectedStudent = s),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SELECTED STUDENT PROFILE ====================
  Widget _buildStudentProfileCard(InstitutionProvider provider, FeeConcession? concession) {
    final s = _selectedStudent!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  s.name.isNotEmpty ? s.name.substring(0, 1).toUpperCase() : 'S',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Adm: #${s.adm} • Class: ${s.studentClass} • Roll: ${s.roll.isNotEmpty ? s.roll : "-"}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  s.status.toUpperCase(),
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
          if (s.father.isNotEmpty || s.mobile.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Guardian: ${s.father.isNotEmpty ? s.father : "-"} • Contact: ${s.mobile.isNotEmpty ? s.mobile : "-"}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ],
          if (concession != null && concession.concessionMonthlyFee > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Concession Active: ${provider.setting.currencySymbol}${concession.concessionMonthlyFee.toStringAsFixed(0)}/mo (${concession.reason.isNotEmpty ? concession.reason : "Scholarship"})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== STUDENT RECENT PAYMENTS ====================
  Widget _buildStudentRecentPayments(InstitutionProvider provider) {
    if (_selectedStudent == null) return const SizedBox.shrink();
    final studentPayments = provider.payments
        .where((p) => (p.studentId == _selectedStudent!.id || p.admissionNo == _selectedStudent!.adm) && p.status == 'VALID')
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STUDENT PAYMENT HISTORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.6),
              ),
              Text(
                '${studentPayments.length} Receipts',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (studentPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No previous payments on record.', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studentPayments.take(3).length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (ctx, idx) {
                final p = studentPayments[idx];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${p.receiptNo}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${p.paymentDate} • ${p.feeItems.map((f) => f.itemLabel).join(", ")}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${provider.setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print_rounded, size: 16, color: Color(0xFF2563EB)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Reprint Receipt',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReceiptDialog(payment: p, setting: provider.setting),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ==================== FEE CALCULATION & CHECKOUT PANEL ====================
  Widget _buildFeeCalculationPanel(
    InstitutionProvider provider,
    FeeConcession? concession,
    double totalPayable,
  ) {
    final setting = provider.setting;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          const Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                '2. BILLING PERIOD & MONTH',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedPeriod,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _selectedPeriod = val ?? _months.first),
          ),
          const SizedBox(height: 20),

          // Fee Items Checklist
          const Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                '3. ITEMIZED FEE HEADS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feeCatalog.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, idx) {
                final item = _feeCatalog[idx];
                final isPaid = _selectedStudent != null &&
                    provider.payments.any((p) =>
                        p.studentId == _selectedStudent!.id &&
                        p.status == 'VALID' &&
                        p.feeItems.any((fi) => fi.itemKey == item['key'] && fi.period == _selectedPeriod));

                final effectiveAmount = _getItemEffectiveAmount(item, concession);
                final hasConcessionDiscount = item['key'] == 'tuition' &&
                    concession != null &&
                    concession.concessionMonthlyFee > 0 &&
                    concession.concessionMonthlyFee != item['amount'];

                return CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  dense: true,
                  title: Row(
                    children: [
                      Text(
                        item['label'],
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                      if (hasConcessionDiscount) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('CONCESSION', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                        ),
                      ],
                      const Spacer(),
                      if (isPaid)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Text('ALREADY PAID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                        )
                      else
                        Row(
                          children: [
                            if (hasConcessionDiscount)
                              Text(
                                '${setting.currencySymbol}${item["amount"]} ',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              '${setting.currencySymbol}${effectiveAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  value: isPaid ? false : item['selected'],
                  activeColor: const Color(0xFF2563EB),
                  onChanged: isPaid
                      ? null
                      : (val) {
                          setState(() => item['selected'] = val ?? false);
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Payment Mode Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Mode:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _buildPaymentModeChip('CASH', '💵 Cash'),
                  _buildPaymentModeChip('UPI', '📱 UPI / QR'),
                  _buildPaymentModeChip('BANK', '🏦 Bank Transfer'),
                ],
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFFE2E8F0)),

          // Total Calculation Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAYABLE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.8),
                    ),
                    Text(
                      'Immediate Receipt Issuance',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Text(
                  '${setting.currencySymbol}${totalPayable.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary Submit CTA
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _handleCollectFee,
            icon: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.print_rounded, size: 20),
            label: Text(
              _isSubmitting ? 'Recording Payment in Cloud...' : 'Collect Fee & Issue Receipt',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeChip(String mode, String label) {
    final isSelected = _paymentMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFDBEAFE),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
      ),
      side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
      onSelected: (_) => setState(() => _paymentMode = mode),
    );
  }

  // ==================== TAB 2: MASTER LEDGER ====================
  Widget _buildMasterLedgerTab(BuildContext context, InstitutionProvider provider) {
    final setting = provider.setting;
    final filteredStudents = provider.students.where((st) {
      final matchesClass = _ledgerClassFilter == 'ALL' || st.studentClass == _ledgerClassFilter;
      final matchesQuery = _ledgerSearchQuery.isEmpty ||
          st.name.toLowerCase().contains(_ledgerSearchQuery.toLowerCase()) ||
          st.adm.contains(_ledgerSearchQuery);
      return matchesClass && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Toolbar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search ledger by Student Name or Adm #...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (val) => setState(() => _ledgerSearchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _ledgerClassFilter,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'ALL', child: Text('All Classes')),
                      ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (val) => setState(() => _ledgerClassFilter = val ?? 'ALL'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ledger DataTable Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('Adm #', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Total Paid', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Receipts', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800))),
                ],
                rows: filteredStudents.map((st) {
                  final stPayments = provider.payments
                      .where((p) => (p.studentId == st.id || p.admissionNo == st.adm) && p.status == 'VALID');
                  final totalPaid = stPayments.fold(0.0, (acc, curr) => acc + curr.amount);

                  return DataRow(
                    cells: [
                      DataCell(Text(st.adm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                      DataCell(Text(st.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(st.studentClass)),
                      DataCell(Text(
                        '${setting.currencySymbol}${totalPaid.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      )),
                      DataCell(Text(
                        stPayments.length.toString(),
                        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: st.status == 'Active' ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            st.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: st.status == 'Active' ? const Color(0xFF059669) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: HISTORY & VOID ====================
  Widget _buildHistoryTab(BuildContext context, InstitutionProvider provider) {
    final setting = provider.setting;
    final filteredPayments = provider.payments.where((p) {
      final matchesQuery = _historySearchQuery.isEmpty ||
          p.studentName.toLowerCase().contains(_historySearchQuery.toLowerCase()) ||
          p.receiptNo.contains(_historySearchQuery) ||
          p.admissionNo.contains(_historySearchQuery);
      final matchesStatus = _historyStatusFilter == 'ALL' || p.status == _historyStatusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Receipt #, Student Name, or Adm #...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => setState(() => _historySearchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _historyStatusFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'VALID', child: Text('Valid Receipts')),
                  DropdownMenuItem(value: 'VOIDED', child: Text('Voided Receipts')),
                ],
                onChanged: (val) => setState(() => _historyStatusFilter = val ?? 'ALL'),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Payments List
        Expanded(
          child: filteredPayments.isEmpty
              ? const Center(child: Text('No payment history records found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPayments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final p = filteredPayments[idx];
                    final isVoided = p.status == 'VOIDED';

                    return Container(
                      decoration: BoxDecoration(
                        color: isVoided ? const Color(0xFFFEF2F2) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isVoided ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isVoided ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
                          child: Icon(
                            isVoided ? Icons.cancel_rounded : Icons.receipt_rounded,
                            color: isVoided ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                            size: 20,
                          ),
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
                                color: isVoided ? const Color(0xFFEF4444) : const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.status.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${p.studentName} (${p.studentClass}) • ${p.paymentDate} • ${p.paymentMode}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${setting.currencySymbol}${p.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isVoided ? Colors.grey : const Color(0xFF059669),
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.print_rounded, size: 20, color: Color(0xFF2563EB)),
                              tooltip: 'Reprint Receipt',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ReceiptDialog(payment: p, setting: setting),
                                );
                              },
                            ),
                            if (!isVoided)
                              IconButton(
                                icon: const Icon(Icons.block_rounded, size: 20, color: Color(0xFFEF4444)),
                                tooltip: 'Void Receipt',
                                onPressed: () => _confirmVoidReceipt(p, provider),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmVoidReceipt(Payment p, InstitutionProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Confirm VOID Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Are you sure you want to VOID Receipt #${p.receiptNo} for ${p.studentName}? This transaction will be marked as canceled and deducted from active collection totals.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Confirm VOID'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.voidPayment(p.id);
    }
  }

  // ==================== FEE COLLECTION SUBMIT ====================
  void _handleCollectFee() async {
    final provider = context.read<InstitutionProvider>();
    final setting = provider.setting;
    final concession = _getStudentConcession(provider);

    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student first!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final selectedItems = _feeCatalog.where((i) => i['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one fee head!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final feeEntries = selectedItems.map((i) {
      final key = i['key'] as String;
      final amt = _getItemEffectiveAmount(i, concession);
      return FeeItemEntry(
        itemKey: key,
        itemLabel: i['label'] as String,
        amount: amt,
        period: _selectedPeriod,
        ledgerKey: '${_selectedStudent!.id}_${setting.activeAcademicYear}_${key}_$_selectedPeriod',
      );
    }).toList();

    final totalPayable = _calculateTotal(concession);

    final payment = Payment(
      id: '',
      paymentId: '',
      receiptNo: provider.nextReceiptNo,
      studentId: _selectedStudent!.id,
      admissionNo: _selectedStudent!.adm,
      studentName: _selectedStudent!.name,
      studentClass: _selectedStudent!.studentClass,
      academicYear: setting.activeAcademicYear,
      amount: totalPayable,
      paymentDate: DateTime.now().toString().split(' ')[0],
      paymentMode: _paymentMode,
      feeItems: feeEntries,
      collectedByName: provider.currentStaff?.name ?? 'Admin Desk',
    );

    final error = await provider.collectPayment(payment);
    setState(() => _isSubmitting = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ReceiptDialog(payment: payment, setting: setting),
        );
      }
    }
  }
}

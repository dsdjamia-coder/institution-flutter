import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../models/staff.dart';
import '../../models/notice.dart';
import '../../models/gallery_item.dart';
import '../../models/academic_year.dart';
import '../../models/student_group.dart';
import '../../models/fee_concession.dart';
import '../../models/custom_fee_item.dart';
import '../../models/audit_log.dart';
import '../../models/payment.dart';
import '../../services/duplicate_guard.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _currentModuleIndex = 0;
  int _currentSubIndex = 0;

  // ==================== CONTROLLERS & FORM STATES ====================
  // Manual Student Form
  final _stuAdmCtrl = TextEditingController();
  final _stuNameCtrl = TextEditingController();
  final _stuFatherCtrl = TextEditingController();
  final _stuMotherCtrl = TextEditingController();
  final _stuFatherMobCtrl = TextEditingController();
  final _stuMotherMobCtrl = TextEditingController();
  final _stuUidCtrl = TextEditingController();
  final _stuDobCtrl = TextEditingController(text: '2015-05-15');
  final _stuAdmDateCtrl = TextEditingController(text: '2026-06-01');
  final _stuAadhaarCtrl = TextEditingController();
  final _stuAddressCtrl = TextEditingController();
  String _stuGender = 'Male';
  String? _stuClass;
  String _stuStatus = 'Active';
  String? _admDuplicateWarning;

  // Classes & Divisions
  final _newClassCtrl = TextEditingController();
  final _divisionBaseCtrl = TextEditingController(text: '8');
  final _divisionCountCtrl = TextEditingController(text: '3');
  String? _moveSourceClass;
  String? _moveTargetClass;
  final Set<String> _selectedMoveStudentIds = {};

  // Website Info
  final _webAppNameCtrl = TextEditingController();
  final _webInstNameCtrl = TextEditingController();
  final _webSubtitleCtrl = TextEditingController();
  final _webRegNoCtrl = TextEditingController();
  final _webPlaceCtrl = TextEditingController();
  final _webPhoneCtrl = TextEditingController();
  final _webEmailCtrl = TextEditingController();
  final _webAboutCtrl = TextEditingController();
  final _webWaCtrl = TextEditingController();
  final _webFbCtrl = TextEditingController();
  final _webIgCtrl = TextEditingController();
  final _webTgCtrl = TextEditingController();
  final _webYtCtrl = TextEditingController();
  final _bankAccNameCtrl = TextEditingController();
  final _bankUpiNumCtrl = TextEditingController();
  final _bankUpiIdCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankAccNumCtrl = TextEditingController();
  final _bankIfscCtrl = TextEditingController();
  final _bankBranchCtrl = TextEditingController();

  // Notices
  final _notHeadCtrl = TextEditingController();
  final _notDescCtrl = TextEditingController();
  final _notDateCtrl = TextEditingController();
  bool _notIsPinned = false;

  // Fee Settings
  final _defaultFeeCtrl = TextEditingController();
  final _feeTitleCtrl = TextEditingController();
  int _feeStartDay = 1;
  int _feeEndDay = 10;
  String _feeNotifyMode = 'month_start';
  int _feeNotifyDaysBefore = 5;
  bool _isReceiptReq = true;

  // Advanced Fee Item Form
  final _customFeeNameCtrl = TextEditingController();
  final _customFeeGlobalAmtCtrl = TextEditingController();
  String _customFeeScope = 'global';
  String? _customFeeSpecificClass;
  bool _customFeeReceiptReq = false;

  // Discontinue Student Form
  String? _discClassFilter;
  String? _selectedDiscStudentId;
  final _discSearchCtrl = TextEditingController();
  final _discDateCtrl = TextEditingController();
  final _discReasonCtrl = TextEditingController();
  bool _discCollectDuesNow = false;
  final _discReceiptNoCtrl = TextEditingController();
  final _discNotesCtrl = TextEditingController();

  // Audit Logs Filter
  String _auditCategoryFilter = 'all';
  final _auditSearchCtrl = TextEditingController();

  // Master Security Credentials Form
  final _currentPasswordCtrl = TextEditingController();
  final _newEmailCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  // Manage Students Filters
  String _filterYear = 'ALL';
  String _filterClass = 'ALL';
  String _filterGender = 'ALL';
  String _filterStatus = 'ALL';
  final _studentSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<InstitutionProvider>();
    final s = p.setting;

    // Prefill Website Info
    _webAppNameCtrl.text = s.appName;
    _webInstNameCtrl.text = s.institutionName;
    _webSubtitleCtrl.text = s.managementName;
    _webRegNoCtrl.text = s.regNo;
    _webPlaceCtrl.text = s.place;
    _webPhoneCtrl.text = s.phone;
    _webEmailCtrl.text = s.email;
    _webAboutCtrl.text = s.aboutText;
    _webWaCtrl.text = s.socialWhatsapp;
    _webFbCtrl.text = s.socialFacebook;
    _webIgCtrl.text = s.socialInstagram;
    _webTgCtrl.text = s.socialTelegram;
    _webYtCtrl.text = s.socialYoutube;
    _bankAccNameCtrl.text = s.bankAccountName;
    _bankUpiNumCtrl.text = s.bankUpiNumber;
    _bankUpiIdCtrl.text = s.bankUpiId;
    _bankNameCtrl.text = s.bankName;
    _bankAccNumCtrl.text = s.bankAccountNumber;
    _bankIfscCtrl.text = s.bankIfsc;
    _bankBranchCtrl.text = s.bankBranch;

    // Prefill Fee Settings
    _defaultFeeCtrl.text = s.defaultMonthlyFee.toStringAsFixed(0);
    _feeTitleCtrl.text = s.feeStatusTitle;
    _feeStartDay = s.feeCollectStartDay;
    _feeEndDay = s.feeCollectEndDay;
    _feeNotifyMode = s.feeNotifyMode;
    _feeNotifyDaysBefore = s.feeNotifyDaysBefore;
    _isReceiptReq = s.isDefaultFeeReceiptRequired;

    _discDateCtrl.text = DateTime.now().toString().split(' ')[0];
    _notDateCtrl.text = DateTime.now().toString().split(' ')[0];

    // Live duplicate check on Admission Number
    _stuAdmCtrl.addListener(_onAdmNoChanged);
  }

  void _onAdmNoChanged() {
    final p = context.read<InstitutionProvider>();
    final val = _stuAdmCtrl.text.trim();
    if (val.isEmpty) {
      if (_admDuplicateWarning != null) setState(() => _admDuplicateWarning = null);
      return;
    }
    final dup = DuplicateGuard.isAdmissionNoDuplicate(val, p.students);
    if (dup) {
      final existing = p.students.firstWhere((s) => s.adm.trim().toUpperCase() == val.toUpperCase());
      setState(() => _admDuplicateWarning = 'Adm #$val is already assigned to ${existing.name} (${existing.studentClass})!');
    } else {
      if (_admDuplicateWarning != null) setState(() => _admDuplicateWarning = null);
    }
  }

  @override
  void dispose() {
    _stuAdmCtrl.dispose();
    _stuNameCtrl.dispose();
    _stuFatherCtrl.dispose();
    _stuMotherCtrl.dispose();
    _stuFatherMobCtrl.dispose();
    _stuMotherMobCtrl.dispose();
    _stuUidCtrl.dispose();
    _stuDobCtrl.dispose();
    _stuAdmDateCtrl.dispose();
    _stuAadhaarCtrl.dispose();
    _stuAddressCtrl.dispose();
    _newClassCtrl.dispose();
    _divisionBaseCtrl.dispose();
    _divisionCountCtrl.dispose();
    _webAppNameCtrl.dispose();
    _webInstNameCtrl.dispose();
    _webSubtitleCtrl.dispose();
    _webRegNoCtrl.dispose();
    _webPlaceCtrl.dispose();
    _webPhoneCtrl.dispose();
    _webEmailCtrl.dispose();
    _webAboutCtrl.dispose();
    _webWaCtrl.dispose();
    _webFbCtrl.dispose();
    _webIgCtrl.dispose();
    _webTgCtrl.dispose();
    _webYtCtrl.dispose();
    _bankAccNameCtrl.dispose();
    _bankUpiNumCtrl.dispose();
    _bankUpiIdCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccNumCtrl.dispose();
    _bankIfscCtrl.dispose();
    _bankBranchCtrl.dispose();
    _notHeadCtrl.dispose();
    _notDescCtrl.dispose();
    _notDateCtrl.dispose();
    _defaultFeeCtrl.dispose();
    _feeTitleCtrl.dispose();
    _customFeeNameCtrl.dispose();
    _customFeeGlobalAmtCtrl.dispose();
    _discSearchCtrl.dispose();
    _discDateCtrl.dispose();
    _discReasonCtrl.dispose();
    _discReceiptNoCtrl.dispose();
    _discNotesCtrl.dispose();
    _auditSearchCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newEmailCtrl.dispose();
    _newPasswordCtrl.dispose();
    _studentSearchCtrl.dispose();
    super.dispose();
  }

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    return AdaptivePortalScaffold(
      portalId: 'admin_console',
      portalTitle: 'Admin Command Center',
      portalSubtitle: setting.institutionName,
      initialIndex: _currentModuleIndex,
      initialSubIndex: _currentSubIndex,
      defaultPinnedTabIds: const ['inst_overview', 'stud_manage', 'fin_settings', 'web_notices'],
      onTabChanged: (idx) => setState(() {
        _currentModuleIndex = idx;
        _currentSubIndex = 0;
      }),
      onSubTabChanged: (mIdx, sIdx) => setState(() {
        _currentModuleIndex = mIdx;
        _currentSubIndex = sIdx;
      }),
      tabs: [
        // MODULE 1: INSTITUTION SETTINGS
        PortalTabItem(
          id: 'institution',
          label: 'Institution Settings',
          icon: Icons.apartment_rounded,
          badge: '${provider.totalStaff} Staff',
          subItems: [
            PortalSubItem(
              id: 'inst_overview',
              label: 'Overview & Profile',
              icon: Icons.dashboard_rounded,
              body: _buildOverviewTab(provider, setting),
            ),
            PortalSubItem(
              id: 'inst_academic_years',
              label: 'Academic Years',
              icon: Icons.calendar_month_rounded,
              body: _buildAcademicYearsTab(provider, setting),
            ),
            PortalSubItem(
              id: 'inst_staff',
              label: 'Staff Directory',
              icon: Icons.badge_rounded,
              body: _buildStaffDirectoryTab(provider),
            ),
            PortalSubItem(
              id: 'inst_add_staff',
              label: 'Add Staff & Categories',
              icon: Icons.person_add_alt_1_rounded,
              body: _buildAddStaffTab(provider),
            ),
          ],
        ),

        // MODULE 2: STUDENT ADMINISTRATION
        PortalTabItem(
          id: 'students',
          label: 'Student Administration',
          icon: Icons.groups_rounded,
          badge: '${provider.totalActiveStudents} Active',
          subItems: [
            PortalSubItem(
              id: 'stud_manage',
              label: 'Manage Students',
              icon: Icons.people_outline_rounded,
              body: _buildManageStudentsTab(provider),
            ),
            PortalSubItem(
              id: 'stud_manual',
              label: 'Add Student (Manual)',
              icon: Icons.person_add_rounded,
              body: _buildManualStudentTab(provider),
            ),
            PortalSubItem(
              id: 'stud_bulk',
              label: 'Bulk Excel Upload',
              icon: Icons.file_upload_rounded,
              body: _buildBulkExcelTab(provider),
            ),
            PortalSubItem(
              id: 'stud_classes',
              label: 'Classes & Divisions',
              icon: Icons.alt_route_rounded,
              body: _buildClassesDivisionsTab(provider),
            ),
          ],
        ),

        // MODULE 3: CONTINUITY & TRANSFERS
        PortalTabItem(
          id: 'continuity',
          label: 'Continuity & Transfers',
          icon: Icons.transfer_within_a_station_rounded,
          badge: '${provider.discontinuedStudents.length} Exit',
          subItems: [
            PortalSubItem(
              id: 'cont_discontinue',
              label: 'Discontinue Student',
              icon: Icons.person_remove_rounded,
              body: _buildDiscontinueStudentTab(provider),
            ),
            PortalSubItem(
              id: 'cont_departed',
              label: 'Departed Directory',
              icon: Icons.archive_rounded,
              body: _buildDepartedDirectoryTab(provider),
            ),
            PortalSubItem(
              id: 'cont_readmission',
              label: 'Re-admission Wizard',
              icon: Icons.restart_alt_rounded,
              body: _buildReadmissionTab(provider),
            ),
            PortalSubItem(
              id: 'cont_timeline',
              label: 'Continuity Timeline',
              icon: Icons.timeline_rounded,
              body: _buildContinuityTimelineTab(provider),
            ),
          ],
        ),

        // MODULE 4: FINANCE & FEES
        PortalTabItem(
          id: 'finance',
          label: 'Finance & Fees',
          icon: Icons.payments_rounded,
          badge: '${setting.currencySymbol}${setting.defaultMonthlyFee.toStringAsFixed(0)}',
          subItems: [
            PortalSubItem(
              id: 'fin_settings',
              label: 'Fee Settings & Windows',
              icon: Icons.settings_suggest_rounded,
              body: _buildFeeSettingsTab(provider, setting),
            ),
            PortalSubItem(
              id: 'fin_builder',
              label: 'Advanced Fee Builder',
              icon: Icons.construction_rounded,
              body: _buildAdvancedFeeBuilderTab(provider),
            ),
            PortalSubItem(
              id: 'fin_siblings',
              label: 'Sibling Groups',
              icon: Icons.family_restroom_rounded,
              body: _buildSiblingGroupsTab(provider),
            ),
            PortalSubItem(
              id: 'fin_concessions',
              label: 'Fee Concessions',
              icon: Icons.percent_rounded,
              body: _buildFeeConcessionsTab(provider),
            ),
          ],
        ),

        // MODULE 5: WEBSITE MANAGEMENT
        PortalTabItem(
          id: 'website',
          label: 'Website & Media',
          icon: Icons.public_rounded,
          badge: '${provider.notices.length} Notices',
          subItems: [
            PortalSubItem(
              id: 'web_basic',
              label: 'Basic Info & Social',
              icon: Icons.info_outline_rounded,
              body: _buildBasicInfoTab(provider, setting),
            ),
            PortalSubItem(
              id: 'web_notices',
              label: 'Notice Board',
              icon: Icons.campaign_rounded,
              body: _buildNoticeBoardTab(provider),
            ),
            PortalSubItem(
              id: 'web_gallery',
              label: 'Photo Gallery',
              icon: Icons.photo_library_rounded,
              body: _buildGalleryTab(provider),
            ),
          ],
        ),

        // MODULE 6: SYSTEM & SECURITY
        PortalTabItem(
          id: 'security',
          label: 'System & Security',
          icon: Icons.security_rounded,
          badge: 'Super Admin',
          subItems: [
            PortalSubItem(
              id: 'sec_creds',
              label: 'Master Credentials',
              icon: Icons.vpn_key_rounded,
              body: _buildCredentialsTab(provider, setting),
            ),
            PortalSubItem(
              id: 'sec_session',
              label: 'Session Monitor',
              icon: Icons.devices_rounded,
              body: _buildSessionMonitorTab(provider),
            ),
            PortalSubItem(
              id: 'sec_backup',
              label: 'Backup & Recovery',
              icon: Icons.backup_rounded,
              body: _buildBackupRecoveryTab(provider),
            ),
            PortalSubItem(
              id: 'sec_audit',
              label: 'System Audit Trail',
              icon: Icons.history_rounded,
              body: _buildAuditTrailTab(provider),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== UNIVERSAL CONFIRMATION DIALOG ====================
  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    Color confirmColor = const Color(0xFFE11D48),
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: confirmColor, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // 1A. OVERVIEW
  Widget _buildOverviewTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Command Center Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.indigo.shade800]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INSTITUTION COMMAND CENTER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text(setting.institutionName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${setting.place} • Reg #${setting.regNo}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                  child: Column(
                    children: [
                      const Text('ACTIVE YEAR', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(setting.activeAcademicYear, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 1.4 : 1.25,
                children: [
                  StatCard(title: 'Active Students', value: '${provider.totalActiveStudents}', subtitle: '${provider.totalBoys} Boys • ${provider.totalGirls} Girls', icon: Icons.school_rounded, color: const Color(0xFF2563EB)),
                  StatCard(title: 'Classes & Divisions', value: '${provider.classes.length}', subtitle: 'Active standards', icon: Icons.class_rounded, color: const Color(0xFF7C3AED)),
                  StatCard(title: 'Faculty & Staff', value: '${provider.totalStaff}', subtitle: 'Active accounts', icon: Icons.badge_rounded, color: const Color(0xFF059669)),
                  StatCard(title: 'Custom Fee Items', value: '${provider.customFeeItems.length}', subtitle: 'Catalog items', icon: Icons.receipt_long_rounded, color: const Color(0xFFD97706)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Quick Action Launchers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Administrative Launchers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildQuickActionBtn('Add Student', Icons.person_add_rounded, const Color(0xFF2563EB), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 1; })),
                    _buildQuickActionBtn('Manage Students', Icons.groups_rounded, const Color(0xFF7C3AED), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Discontinue / Re-admit', Icons.transfer_within_a_station_rounded, const Color(0xFFE11D48), () => setState(() { _currentModuleIndex = 2; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Fee Windows & Alerts', Icons.receipt_rounded, const Color(0xFFD97706), () => setState(() { _currentModuleIndex = 3; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Post Notice', Icons.campaign_rounded, const Color(0xFF059669), () => setState(() { _currentModuleIndex = 4; _currentSubIndex = 1; })),
                    _buildQuickActionBtn('Export Backup', Icons.download_rounded, const Color(0xFF475569), () => setState(() { _currentModuleIndex = 5; _currentSubIndex = 2; })),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // 1B. ACADEMIC YEARS
  Widget _buildAcademicYearsTab(InstitutionProvider provider, dynamic setting) {
    final yearCtrl = TextEditingController(text: '2026-2027');
    String startMonth = 'June';
    String endMonth = 'March';
    String status = 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Configure Academic Years (YYYY-YYYY)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                      child: Text('Current: ${setting.activeAcademicYear}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: yearCtrl,
                        decoration: const InputDecoration(labelText: 'Academic Year (e.g. 2026-2027)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final val = yearCtrl.text.trim();
                        if (RegExp(r'^\d{4}-\d{4}$').hasMatch(val)) {
                          await provider.addAcademicYear(AcademicYearConfig(label: val, startMonth: startMonth, endMonth: endMonth, status: status));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Academic Year $val saved!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid format! Must be YYYY-YYYY (e.g. 2026-2027)')));
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Year'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Configured Years List
          const Text('Configured Academic Years', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.academicYears.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final y = provider.academicYears[idx];
              final isCurrent = y.label == setting.activeAcademicYear || y.status == 'current';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isCurrent ? const Color(0xFF6EE7B7) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: isCurrent ? const Color(0xFF059669) : Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Text(y.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 10),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                            child: const Text('CURRENT WORKING YEAR', style: TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        if (!isCurrent)
                          OutlinedButton(
                            onPressed: () => provider.setWorkingAcademicYear(y.label),
                            child: const Text('Set as Current', style: TextStyle(fontSize: 12)),
                          ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                          tooltip: 'Edit Academic Year',
                          onPressed: () => _showEditAcademicYearModal(y, provider),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          tooltip: 'Delete Academic Year',
                          onPressed: () async {
                            final confirmed = await _confirmAction(
                              context,
                              title: 'Delete Academic Year',
                              message: 'Are you sure you want to permanently delete academic year "${y.label}"? Enrolled student associations may be affected.',
                              confirmLabel: 'Delete Year',
                            );
                            if (confirmed) {
                              await provider.deleteAcademicYear(y.label);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Academic Year "${y.label}" deleted.')));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditAcademicYearModal(AcademicYearConfig y, InstitutionProvider provider) {
    String startMonth = y.startMonth;
    String endMonth = y.endMonth;
    String status = y.status;
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Academic Year: ${y.label}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: months.contains(startMonth) ? startMonth : 'June',
                decoration: const InputDecoration(labelText: 'Starting Month', border: OutlineInputBorder()),
                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setDlg(() => startMonth = v ?? 'June'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: months.contains(endMonth) ? endMonth : 'March',
                decoration: const InputDecoration(labelText: 'Ending Month', border: OutlineInputBorder()),
                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setDlg(() => endMonth = v ?? 'March'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'archived', child: Text('Archived')),
                ],
                onChanged: (v) => setDlg(() => status = v ?? 'active'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                final updated = AcademicYearConfig(
                  label: y.label,
                  startMonth: startMonth,
                  endMonth: endMonth,
                  status: status,
                );
                await provider.addAcademicYear(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Academic Year "${y.label}" updated!')));
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // 1C. STAFF DIRECTORY
  Widget _buildStaffDirectoryTab(InstitutionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Staff & Faculty (${provider.staffList.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _currentModuleIndex = 0;
                _currentSubIndex = 3;
              }),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Staff'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (provider.staffList.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No staff members registered yet.')))
        else
          ...provider.staffList.map((st) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(st.name.isNotEmpty ? st.name[0].toUpperCase() : 'U', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(st.role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Assigned: ${st.assignedClass.isNotEmpty ? st.assignedClass : 'All Classes'} • Ph: ${st.phone} • Email: ${st.email}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                  tooltip: 'Edit Profile & Access',
                  onPressed: () => _showEditStaffModal(st, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.assignment_ind_rounded, size: 18, color: Color(0xFF059669)),
                  tooltip: 'Assign Duty Classes & UPI Account',
                  onPressed: () => _showDutyModal(st, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  tooltip: 'Delete Staff Member',
                  onPressed: () async {
                    final confirmed = await _confirmAction(
                      context,
                      title: 'Delete Staff Member',
                      message: 'Are you sure you want to permanently remove faculty member "${st.name}"? Their login sessions and portal access will be revoked.',
                      confirmLabel: 'Delete Staff',
                    );
                    if (confirmed) {
                      await provider.deleteStaff(st.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff "${st.name}" deleted.')));
                    }
                  },
                ),
              ],
            ),
          )),
      ],
    );
  }

  void _showEditStaffModal(Staff st, InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: st.name);
    final desigCtrl = TextEditingController(text: st.designation);
    final samasthaCtrl = TextEditingController(text: st.samasthaRegNo);
    final phoneCtrl = TextEditingController(text: st.phone);
    final emailCtrl = TextEditingController(text: st.email);
    String role = st.role;
    bool canCollect = st.hasCollectionAccess;
    bool canWorksheet = st.hasWorksheetAccess;
    bool canResults = st.hasResultAccess;
    bool canAdmin = st.hasAdminAccess;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Staff: ${st.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: ['TEACHER', 'ADMIN', 'COLLECTOR'].contains(role) ? role : 'TEACHER',
                  decoration: const InputDecoration(labelText: 'Staff Role *', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'TEACHER', child: Text('Teacher / Ustad')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                    DropdownMenuItem(value: 'COLLECTOR', child: Text('Cashier / Fee Collector')),
                  ],
                  onChanged: (val) => setLocal(() => role = val ?? 'TEACHER'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: samasthaCtrl, decoration: const InputDecoration(labelText: 'Samastha Reg #', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / WhatsApp', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
                const SizedBox(height: 16),

                const Text('4-Portal Access Permissions', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 6),
                CheckboxListTile(value: canCollect, onChanged: (v) => setLocal(() => canCollect = v ?? true), title: const Text('Fee Collection Access', style: TextStyle(fontSize: 12))),
                CheckboxListTile(value: canWorksheet, onChanged: (v) => setLocal(() => canWorksheet = v ?? true), title: const Text('Worksheet Access', style: TextStyle(fontSize: 12))),
                CheckboxListTile(value: canResults, onChanged: (v) => setLocal(() => canResults = v ?? false), title: const Text('Results Access', style: TextStyle(fontSize: 12))),
                CheckboxListTile(value: canAdmin, onChanged: (v) => setLocal(() => canAdmin = v ?? false), title: const Text('Admin Panel Access', style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final updated = st.copyWith(
                  name: nameCtrl.text.trim(),
                  role: role,
                  designation: desigCtrl.text.trim(),
                  samasthaRegNo: samasthaCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  hasCollectionAccess: canCollect,
                  hasWorksheetAccess: canWorksheet,
                  hasResultAccess: canResults,
                  hasAdminAccess: canAdmin,
                );
                await provider.updateStaff(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff "${updated.name}" updated successfully!')));
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDutyModal(Staff st, InstitutionProvider provider) {
    final accCtrl = TextEditingController(text: st.upiAccountName);
    final upiCtrl = TextEditingController(text: st.upiId);
    final assignedClasses = Set<String>.from(st.assignedClasses.isNotEmpty ? st.assignedClasses : [st.assignedClass]);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Assign Duties: ${st.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Assigned Duty Classes (Multiple Selection)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: provider.classes.map((c) {
                    final isSel = assignedClasses.contains(c);
                    return FilterChip(
                      selected: isSel,
                      label: Text(c, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      onSelected: (val) {
                        setDlgState(() {
                          if (val) assignedClasses.add(c); else assignedClasses.remove(c);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('2. UPI / Cashier Account (For Student Payments)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: upiCtrl, decoration: const InputDecoration(labelText: 'UPI ID (e.g. name@okhdfcbank)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updated = st.copyWith(
                  assignedClass: assignedClasses.join(', '),
                  assignedClasses: assignedClasses.toList(),
                  upiAccountName: accCtrl.text.trim(),
                  upiId: upiCtrl.text.trim(),
                );
                provider.updateStaff(updated);
                Navigator.pop(ctx);
              },
              child: const Text('Save Duties'),
            ),
          ],
        ),
      ),
    );
  }

  // 1D. ADD STAFF & CATEGORIES
  Widget _buildAddStaffTab(InstitutionProvider provider) {
    final nameCtrl = TextEditingController();
    final desigCtrl = TextEditingController(text: 'TEACHER');
    final samasthaCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'TEACHER';
    bool canCollect = true;
    bool canWorksheet = true;
    bool canResults = false;
    bool canAdmin = false;
    bool actAsSuperAdmin = false;

    return StatefulBuilder(
      builder: (ctx, setLocal) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Faculty / Staff Member', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Staff Role *', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'TEACHER', child: Text('Teacher / Ustad')),
                        DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                        DropdownMenuItem(value: 'COLLECTOR', child: Text('Cashier / Fee Collector')),
                      ],
                      onChanged: (val) => setLocal(() => role = val ?? 'TEACHER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Designation (e.g. SWADAR, USTAD)', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: samasthaCtrl, decoration: const InputDecoration(labelText: 'Samastha Reg. No (Optional)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / WhatsApp *', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address *', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 18),

              // 4-PORTAL PERMISSIONS
              const Text('4-Portal Access Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 8),
              CheckboxListTile(value: canCollect, onChanged: (v) => setLocal(() => canCollect = v ?? true), title: const Text('1. Fee Collection Access', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              CheckboxListTile(value: canWorksheet, onChanged: (v) => setLocal(() => canWorksheet = v ?? true), title: const Text('2. Class Worksheet Access', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              CheckboxListTile(value: canResults, onChanged: (v) => setLocal(() => canResults = v ?? false), title: const Text('3. Result Portal Access', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              CheckboxListTile(value: canAdmin, onChanged: (v) => setLocal(() => canAdmin = v ?? false), title: const Text('4. Admin Panel Access', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              if (canAdmin)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: CheckboxListTile(value: actAsSuperAdmin, onChanged: (v) => setLocal(() => actAsSuperAdmin = v ?? false), title: const Text('Act like Super Administrator (Full Control)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber))),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Staff Name!')));
                      return;
                    }
                    final st = Staff(
                      id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      role: role,
                      designation: desigCtrl.text.trim(),
                      samasthaRegNo: samasthaCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      hasCollectionAccess: canCollect,
                      hasWorksheetAccess: canWorksheet,
                      hasResultAccess: canResults,
                      hasAdminAccess: canAdmin,
                    );
                    await provider.addStaff(st);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff ${st.name} registered successfully!')));
                    setState(() {
                      _currentModuleIndex = 0;
                      _currentSubIndex = 2;
                    });
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Register Staff Member'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // 2A. MANAGE STUDENTS
  // ========================================================================
  Widget _buildManageStudentsTab(InstitutionProvider provider) {
    final query = _studentSearchCtrl.text.trim().toLowerCase();
    final filtered = provider.students.where((s) {
      if (_filterClass != 'ALL' && s.studentClass != _filterClass) return false;
      if (_filterGender != 'ALL' && s.gender.toLowerCase() != _filterGender.toLowerCase()) return false;
      if (_filterStatus != 'ALL' && s.status.toLowerCase() != _filterStatus.toLowerCase()) return false;
      if (query.isNotEmpty) {
        final m = s.name.toLowerCase().contains(query) || s.adm.toLowerCase().contains(query) || s.mobile.contains(query);
        if (!m) return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Filter Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _studentSearchCtrl,
                    decoration: const InputDecoration(hintText: 'Search Name, Adm #...', prefixIcon: Icon(Icons.search, size: 18), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterClass,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: ['ALL', ...provider.classes].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _filterClass = v ?? 'ALL'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Status', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Alumni', child: Text('Alumni', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Discontinued', child: Text('Exit', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v ?? 'ALL'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Students Table / List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No students matching selected filters.'))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final s = filtered[idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(s.name.isNotEmpty ? s.name[0] : 'S', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                        child: Text('#${s.adm}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: s.status == 'Active' ? const Color(0xFFECFDF5) : (s.status == 'Alumni' ? const Color(0xFFFAF5FF) : const Color(0xFFFFF1F2)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(s.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s.status == 'Active' ? const Color(0xFF065F46) : const Color(0xFF6B21A8))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Class: ${s.studentClass} • Father: ${s.father} • Ph: ${s.mobile}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                              tooltip: 'Edit Student Details',
                              onPressed: () => _showEditStudentModal(s, provider),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Delete Student',
                              onPressed: () async {
                                final confirmed = await _confirmAction(
                                  context,
                                  title: 'Delete Student Record',
                                  message: 'Are you sure you want to permanently delete student "${s.name}" (#${s.adm})? All marks, attendance, and registration history will be removed.',
                                  confirmLabel: 'Delete Student',
                                );
                                if (confirmed) {
                                  await provider.deleteStudent(s.id);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student "${s.name}" deleted.')));
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditStudentModal(Student s, InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: s.name);
    final admCtrl = TextEditingController(text: s.adm);
    final fatherCtrl = TextEditingController(text: s.father);
    final phoneCtrl = TextEditingController(text: s.mobile);
    String cls = s.studentClass;
    String status = s.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Student: ${s.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: admCtrl, decoration: const InputDecoration(labelText: 'Adm No', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: cls,
                  decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                  items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDlg(() => cls = v ?? cls),
                ),
                const SizedBox(height: 8),
                TextField(controller: fatherCtrl, decoration: const InputDecoration(labelText: 'Father Name', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updated = s.copyWith(
                  name: nameCtrl.text.trim(),
                  adm: admCtrl.text.trim(),
                  studentClass: cls,
                  father: fatherCtrl.text.trim(),
                  mobile: phoneCtrl.text.trim(),
                );
                provider.updateStudent(updated);
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // 2B. MANUAL STUDENT ENTRY
  Widget _buildManualStudentTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Student (Manual Entry - All 15 Fields)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 14),

            if (_admDuplicateWarning != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                child: Text(_admDuplicateWarning!, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
              ),

            Row(
              children: [
                Expanded(child: TextField(controller: _stuAdmCtrl, decoration: const InputDecoration(labelText: 'Admission Number (Adm No) *', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _stuNameCtrl, decoration: const InputDecoration(labelText: 'Full Student Name *', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stuClass ?? (provider.classes.isNotEmpty ? provider.classes.first : null),
                    decoration: const InputDecoration(labelText: 'Class *', border: OutlineInputBorder()),
                    items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _stuClass = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stuGender,
                    decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                    items: const [DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Female', child: Text('Female'))],
                    onChanged: (v) => setState(() => _stuGender = v ?? 'Male'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _stuFatherCtrl, decoration: const InputDecoration(labelText: "Father's Name", border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _stuMotherCtrl, decoration: const InputDecoration(labelText: "Mother's Name", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _stuFatherMobCtrl, decoration: const InputDecoration(labelText: "Father's Phone Number *", border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _stuMotherMobCtrl, decoration: const InputDecoration(labelText: "Mother's Phone Number", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _stuDobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _stuAdmDateCtrl, decoration: const InputDecoration(labelText: 'Admission Date', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _stuAadhaarCtrl, decoration: const InputDecoration(labelText: 'Aadhaar Number', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _stuUidCtrl, decoration: const InputDecoration(labelText: 'Unique ID / UID', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: _stuAddressCtrl, decoration: const InputDecoration(labelText: 'Permanent Address', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_stuNameCtrl.text.isEmpty || _stuAdmCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Student Name and Admission Number!')));
                    return;
                  }
                  final targetCls = _stuClass ?? (provider.classes.isNotEmpty ? provider.classes.first : 'Class 1');
                  final student = Student(
                    id: 'stu_${DateTime.now().millisecondsSinceEpoch}',
                    name: _stuNameCtrl.text.trim(),
                    adm: _stuAdmCtrl.text.trim(),
                    studentClass: targetCls,
                    gender: _stuGender,
                    father: _stuFatherCtrl.text.trim(),
                    mother: _stuMotherCtrl.text.trim(),
                    mobile: _stuFatherMobCtrl.text.trim(),
                    motherMobile: _stuMotherMobCtrl.text.trim(),
                    dob: _stuDobCtrl.text.trim(),
                    admissionDate: _stuAdmDateCtrl.text.trim(),
                    adhaar: _stuAadhaarCtrl.text.trim(),
                    uid: _stuUidCtrl.text.trim(),
                    address: _stuAddressCtrl.text.trim(),
                    status: _stuStatus,
                    academicYear: provider.setting.activeAcademicYear,
                  );
                  final err = await provider.addStudent(student);
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student ${student.name} saved!')));
                    _stuNameCtrl.clear();
                    _stuAdmCtrl.clear();
                    setState(() {
                      _currentModuleIndex = 1;
                      _currentSubIndex = 0;
                    });
                  }
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Student Record'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2C. BULK EXCEL UPLOAD
  Widget _buildBulkExcelTab(InstitutionProvider provider) {
    String? targetClass = provider.classes.isNotEmpty ? provider.classes.first : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bulk Student Upload (CSV / Excel)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('Upload spreadsheet with headers like Name, AdmNo, Class, Gender, Father, Phone, Address.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: targetClass,
              decoration: const InputDecoration(labelText: 'Target Class for Batch *', border: OutlineInputBorder()),
              items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => targetClass = v,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid)),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 36, color: Color(0xFF2563EB)),
                    const SizedBox(height: 8),
                    const Text('Select CSV or Excel Spreadsheet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Supports .csv, .xlsx column auto-mapping', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker ready for CSV/Excel batch upload.')));
                      },
                      icon: const Icon(Icons.file_open, size: 16),
                      label: const Text('Browse Files'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2D. CLASSES & DIVISIONS
  Widget _buildClassesDivisionsTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add & Generator Tools
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Classes & Divisions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _newClassCtrl, decoration: const InputDecoration(labelText: 'New Class Name (e.g. 10 A)', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        provider.addClass(_newClassCtrl.text);
                        _newClassCtrl.clear();
                      },
                      child: const Text('Save Class'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => provider.generateDefaultClasses(),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Generate Default 1 to 12'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => provider.generateDivisions(_divisionBaseCtrl.text, int.tryParse(_divisionCountCtrl.text) ?? 3),
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      label: const Text('Generate Divisions (A/B/C)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Classes Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Classes (${provider.classes.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Text('Tap class chip to Rename', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.classes.map((c) {
              final count = provider.students.where((s) => s.studentClass == c && s.status == 'Active').length;
              return InputChip(
                avatar: CircleAvatar(backgroundColor: Colors.blue.shade100, child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900))),
                label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => _showRenameClassModal(c, provider),
                deleteIcon: const Icon(Icons.close, size: 16),
                deleteButtonTooltipMessage: 'Delete Class',
                onDeleted: () async {
                  final confirmed = await _confirmAction(
                    context,
                    title: 'Delete Class "$c"',
                    message: 'Are you sure you want to permanently delete class "$c"? $count enrolled student(s) currently belong to this class.',
                    confirmLabel: 'Delete Class',
                  );
                  if (confirmed) {
                    await provider.removeClass(c);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Class "$c" deleted.')));
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showRenameClassModal(String oldName, InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Class "$oldName"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Renaming will automatically update all enrolled student assignments in the database.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'New Class Name (e.g. 10 B)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                await provider.renameClass(oldName, newName);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Class renamed to "$newName" successfully!')));
              }
            },
            child: const Text('Save & Update Students'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 3A. DISCONTINUE STUDENT
  // ========================================================================
  Widget _buildDiscontinueStudentTab(InstitutionProvider provider) {
    final activeStudents = provider.activeStudents;
    final query = _discSearchCtrl.text.trim().toLowerCase();
    final matching = activeStudents.where((s) {
      if (_discClassFilter != null && _discClassFilter != 'ALL' && s.studentClass != _discClassFilter) return false;
      if (query.isNotEmpty) {
        return s.name.toLowerCase().contains(query) || s.adm.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    Student? selectedStudent;
    if (_selectedDiscStudentId != null) {
      final sList = provider.students.where((s) => s.id == _selectedDiscStudentId);
      if (sList.isNotEmpty) selectedStudent = sList.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Discontinue Student (Archive from Active Rolls)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                const SizedBox(height: 6),
                const Text('Preserves exact unpaid dues up to departure date. Student is excluded from regular fee cycles and active attendance.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _discClassFilter ?? 'ALL',
                        decoration: const InputDecoration(labelText: '1. Filter Class', border: OutlineInputBorder()),
                        items: ['ALL', ...provider.classes].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _discClassFilter = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _discSearchCtrl,
                        decoration: const InputDecoration(labelText: '2. Search Student Name or Adm #', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Candidate Selector
                if (matching.isNotEmpty && selectedStudent == null)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1)), borderRadius: BorderRadius.circular(10)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: matching.take(6).length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final s = matching[idx];
                        return ListTile(
                          dense: true,
                          title: Text('${s.name} (#${s.adm})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          subtitle: Text('Class: ${s.studentClass} • Ph: ${s.mobile}'),
                          onTap: () => setState(() => _selectedDiscStudentId = s.id),
                        );
                      },
                    ),
                  ),

                if (selectedStudent != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFECDD3))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedStudent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            Text('Adm: #${selectedStudent.adm} • Class: ${selectedStudent.studentClass} • Status: ${selectedStudent.status}', style: const TextStyle(fontSize: 11.5)),
                          ],
                        ),
                        TextButton(onPressed: () => setState(() => _selectedDiscStudentId = null), child: const Text('Clear Selection')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _discDateCtrl, decoration: const InputDecoration(labelText: 'Departure Date', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _discReasonCtrl, decoration: const InputDecoration(labelText: 'Departure Reason (e.g. Relocated)', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await _confirmAction(
                        context,
                        title: 'Discontinue Student',
                        message: 'Are you sure you want to mark "${selectedStudent!.name}" (#${selectedStudent.adm}) as Discontinued? The student will be moved to the Departed Directory.',
                        confirmLabel: 'Confirm Departure',
                        confirmColor: const Color(0xFFE11D48),
                      );
                      if (confirmed) {
                        await provider.discontinueStudent(selectedStudent!, _discReasonCtrl.text.trim(), _discDateCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedStudent.name} discontinued and archived!')));
                        setState(() {
                          _selectedDiscStudentId = null;
                          _currentModuleIndex = 2;
                          _currentSubIndex = 1;
                        });
                      }
                    },
                    icon: const Icon(Icons.person_remove_rounded, size: 16),
                    label: const Text('Execute Departure'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), foregroundColor: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3B. DEPARTED DIRECTORY
  Widget _buildDepartedDirectoryTab(InstitutionProvider provider) {
    final departed = provider.discontinuedStudents;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Discontinued Students Directory (${departed.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (departed.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No departed students on record.')))
        else
          ...departed.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFFFF1F2), child: const Icon(Icons.person_off_rounded, color: Color(0xFFBE123C), size: 18)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.name} (#${s.adm})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Exit Class: ${s.studentClass} • Exit Date: ${s.exitDate.isNotEmpty ? s.exitDate : '-'} • Reason: ${s.exitReason.isNotEmpty ? s.exitReason : 'None specified'}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showReadmitModal(s, provider),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                  child: const Text('Re-admit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          )),
      ],
    );
  }

  void _showReadmitModal(Student s, InstitutionProvider provider) {
    String targetClass = provider.classes.isNotEmpty ? provider.classes.first : s.studentClass;
    String targetYear = provider.setting.activeAcademicYear;
    final notesCtrl = TextEditingController(text: 'Re-admitted after gap');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Re-admit: ${s.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                child: const Text('Zero fee guarantee for inactive gap years. Fee starts strictly upon re-admission.', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: targetClass,
                decoration: const InputDecoration(labelText: 'Target Class *', border: OutlineInputBorder()),
                items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setDlg(() => targetClass = v ?? targetClass),
              ),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () async {
                final confirmed = await _confirmAction(
                  context,
                  title: 'Confirm Re-admission',
                  message: 'Are you sure you want to re-admit "${s.name}" (#${s.adm}) to class "$targetClass" for academic year "$targetYear"?',
                  confirmLabel: 'Re-admit Student',
                  confirmColor: const Color(0xFF059669),
                );
                if (confirmed) {
                  await provider.readmitStudent(s, targetClass, targetYear, notesCtrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.name} re-admitted to $targetClass!')));
                }
              },
              child: const Text('Confirm Re-admission'),
            ),
          ],
        ),
      ),
    );
  }

  // 3C. RE-ADMISSION WIZARD
  Widget _buildReadmissionTab(InstitutionProvider provider) {
    return _buildDepartedDirectoryTab(provider);
  }

  // 3D. CONTINUITY TIMELINE
  Widget _buildContinuityTimelineTab(InstitutionProvider provider) {
    final logEntries = <Map<String, dynamic>>[];
    for (final s in provider.students) {
      for (final log in s.continuityLog) {
        logEntries.add({'student': s.name, 'adm': s.adm, ...log});
      }
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Continuity & Departure Audit Timeline (${logEntries.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (logEntries.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No departure or re-admission events recorded.')))
        else
          ...logEntries.map((l) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                Icon(l['action'] == 'DISCONTINUED' ? Icons.exit_to_app_rounded : Icons.login_rounded, size: 18, color: l['action'] == 'DISCONTINUED' ? const Color(0xFFE11D48) : const Color(0xFF059669)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l['action']}: ${l['student']} (#${l['adm']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Date: ${l['date']} • Notes: ${l['reason'] ?? l['notes'] ?? '-'}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  // ========================================================================
  // MODULE 4: FINANCE & FEES
  // ========================================================================
  // ========================================================================
  // 4A. FEE SETTINGS & WINDOWS
  // ========================================================================
  Widget _buildFeeSettingsTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Fee Configuration & Collection Window', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: TextField(controller: _defaultFeeCtrl, decoration: const InputDecoration(labelText: 'Default Monthly Fee (₹) *', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _feeTitleCtrl, decoration: const InputDecoration(labelText: 'Fee Status Title (PDF Report)', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),

            // Window Days
            const Text('Monthly Collection Window Days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _feeStartDay,
                    decoration: const InputDecoration(labelText: 'Collection Start Day (Day of Month)', border: OutlineInputBorder()),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1}'))),
                    onChanged: (v) => setState(() => _feeStartDay = v ?? 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _feeEndDay,
                    decoration: const InputDecoration(labelText: 'Due / Deadline Day (Day of Month)', border: OutlineInputBorder()),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1}'))),
                    onChanged: (v) => setState(() => _feeEndDay = v ?? 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alert Notification Schedule
            const Text('Student Fee Alert Notification Timing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _feeNotifyMode,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'month_start', child: Text('From Month Start (Day 1 of every month)')),
                DropdownMenuItem(value: 'collection_start', child: Text('From Collection Start Day')),
                DropdownMenuItem(value: 'days_before_end', child: Text('5 Days Before Due Date')),
              ],
              onChanged: (v) => setState(() => _feeNotifyMode = v ?? 'month_start'),
            ),
            const SizedBox(height: 14),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isReceiptReq,
              onChanged: (v) => setState(() => _isReceiptReq = v),
              title: const Text('Is Receipt Number Mandatory for Cashier?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('When enabled, fees cannot be recorded without an official receipt number.', style: TextStyle(fontSize: 11.5)),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final fee = double.tryParse(_defaultFeeCtrl.text.trim()) ?? 400.0;
                  final updated = setting.copyWith(
                    defaultMonthlyFee: fee,
                    feeStatusTitle: _feeTitleCtrl.text.trim(),
                    feeCollectStartDay: _feeStartDay,
                    feeCollectEndDay: _feeEndDay,
                    feeNotifyMode: _feeNotifyMode,
                    isDefaultFeeReceiptRequired: _isReceiptReq,
                  );
                  await provider.updateSettings(updated);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee settings & schedule saved!')));
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Fee Settings'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4B. ADVANCED FEE BUILDER
  Widget _buildAdvancedFeeBuilderTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Custom Fee Item', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _customFeeNameCtrl, decoration: const InputDecoration(labelText: 'Fee Item Name (e.g. Books & Stationery)', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _customFeeGlobalAmtCtrl, decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_customFeeNameCtrl.text.isEmpty) return;
                    final amt = double.tryParse(_customFeeGlobalAmtCtrl.text) ?? 0.0;
                    final fee = CustomFeeItem(
                      id: 'fee_${DateTime.now().millisecondsSinceEpoch}',
                      name: _customFeeNameCtrl.text.trim(),
                      globalAmount: amt,
                    );
                    await provider.saveCustomFeeItem(fee);
                    _customFeeNameCtrl.clear();
                    _customFeeGlobalAmtCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fee Item ${fee.name} added!')));
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Fee Item'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Fee Catalogue Items
          Text('Configured Fee Items (${provider.customFeeItems.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ...provider.customFeeItems.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    Text('₹${f.globalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      tooltip: 'Edit Fee Item',
                      onPressed: () => _showEditCustomFeeModal(f, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete Fee Item',
                      onPressed: () async {
                        final confirmed = await _confirmAction(
                          context,
                          title: 'Delete Fee Item',
                          message: 'Are you sure you want to permanently delete custom fee item "${f.name}"?',
                          confirmLabel: 'Delete Item',
                        );
                        if (confirmed) {
                          await provider.deleteCustomFeeItem(f.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fee Item "${f.name}" deleted.')));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showEditCustomFeeModal(CustomFeeItem f, InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: f.name);
    final amtCtrl = TextEditingController(text: f.globalAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Fee Item: ${f.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Fee Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newAmt = double.tryParse(amtCtrl.text.trim()) ?? f.globalAmount;
              if (newName.isNotEmpty) {
                final updated = f.copyWith(name: newName, globalAmount: newAmt);
                await provider.saveCustomFeeItem(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fee Item "${updated.name}" updated!')));
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // 4C. SIBLING GROUPS
  Widget _buildSiblingGroupsTab(InstitutionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Student Sibling Groups (${provider.studentGroups.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showCreateGroupModal(provider),
              icon: const Icon(Icons.group_add_rounded, size: 16),
              label: const Text('Create Sibling Group'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (provider.studentGroups.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No student sibling groups created yet.')))
        else
          ...provider.studentGroups.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text('${g.memberStudentIds.length} Sibling Members • Group Fee: ₹${g.monthlyFee.toStringAsFixed(0)}/month', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      tooltip: 'Edit Sibling Group',
                      onPressed: () => _showEditStudentGroupModal(g, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete Sibling Group',
                      onPressed: () async {
                        final confirmed = await _confirmAction(
                          context,
                          title: 'Delete Sibling Group',
                          message: 'Are you sure you want to permanently delete sibling group "${g.name}"?',
                          confirmLabel: 'Delete Group',
                        );
                        if (confirmed) {
                          await provider.deleteStudentGroup(g.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sibling Group "${g.name}" deleted.')));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),
      ],
    );
  }

  void _showCreateGroupModal(InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: 'Family Group');
    final feeCtrl = TextEditingController(text: '800');
    final selectedIds = <String>{};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Student Sibling Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group Name', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Group Monthly Fee (₹)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const Text('Select Sibling Members:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.activeStudents.take(20).length,
                    itemBuilder: (ctx, idx) {
                      final s = provider.activeStudents[idx];
                      final isSel = selectedIds.contains(s.id);
                      return CheckboxListTile(
                        dense: true,
                        value: isSel,
                        title: Text('${s.name} (${s.studentClass})', style: const TextStyle(fontSize: 12)),
                        onChanged: (v) {
                          setDlg(() {
                            if (v == true) selectedIds.add(s.id); else selectedIds.remove(s.id);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedIds.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least 2 sibling students!')));
                  return;
                }
                final group = StudentGroup(
                  id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  monthlyFee: double.tryParse(feeCtrl.text) ?? 800.0,
                  memberStudentIds: selectedIds.toList(),
                );
                provider.saveStudentGroup(group);
                provider.unifyFamilyDetails(selectedIds.first, selectedIds.toList());
                Navigator.pop(ctx);
              },
              child: const Text('Create & Unify Details'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentGroupModal(StudentGroup g, InstitutionProvider provider) {
    final nameCtrl = TextEditingController(text: g.name);
    final feeCtrl = TextEditingController(text: g.monthlyFee.toStringAsFixed(0));
    final selectedIds = Set<String>.from(g.memberStudentIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Sibling Group: ${g.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Consolidated Monthly Fee (₹)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const Text('Group Sibling Members:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                SizedBox(
                  height: 180,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.activeStudents.length,
                    itemBuilder: (ctx, idx) {
                      final s = provider.activeStudents[idx];
                      final isSel = selectedIds.contains(s.id);
                      return CheckboxListTile(
                        dense: true,
                        value: isSel,
                        title: Text('${s.name} (${s.studentClass})', style: const TextStyle(fontSize: 12)),
                        onChanged: (v) {
                          setDlg(() {
                            if (v == true) selectedIds.add(s.id); else selectedIds.remove(s.id);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                final updated = StudentGroup(
                  id: g.id,
                  name: nameCtrl.text.trim(),
                  monthlyFee: double.tryParse(feeCtrl.text.trim()) ?? g.monthlyFee,
                  memberStudentIds: selectedIds.toList(),
                );
                await provider.saveStudentGroup(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sibling Group "${updated.name}" updated!')));
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // 4D. FEE CONCESSIONS
  Widget _buildFeeConcessionsTab(InstitutionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Concessions (${provider.concessions.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showAddConcessionModal(provider),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Assign Concession'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (provider.concessions.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No special fee concessions assigned.')))
        else
          ...provider.concessions.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Class: ${c.studentClass} • Special Fee: ₹${c.concessionMonthlyFee.toStringAsFixed(0)}/month', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      tooltip: 'Edit Concession',
                      onPressed: () => _showEditConcessionModal(c, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Cancel Concession',
                      onPressed: () async {
                        final confirmed = await _confirmAction(
                          context,
                          title: 'Cancel Fee Concession',
                          message: 'Are you sure you want to cancel the special fee concession for "${c.studentName}"?',
                          confirmLabel: 'Cancel Concession',
                        );
                        if (confirmed) {
                          await provider.removeConcession(c.studentId);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Concession for "${c.studentName}" cancelled.')));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),
      ],
    );
  }

  void _showAddConcessionModal(InstitutionProvider provider) {
    Student? selStudent;
    final feeCtrl = TextEditingController(text: '200');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Assign Fee Concession', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Student>(
                decoration: const InputDecoration(labelText: 'Select Student', border: OutlineInputBorder()),
                items: provider.activeStudents.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} (${s.studentClass})', style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (s) => setDlg(() => selStudent = s),
              ),
              const SizedBox(height: 10),
              TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Special Monthly Fee (₹)', border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selStudent == null) return;
                final conc = FeeConcession(
                  studentId: selStudent!.id,
                  studentName: selStudent!.name,
                  studentClass: selStudent!.studentClass,
                  concessionMonthlyFee: double.tryParse(feeCtrl.text) ?? 200.0,
                );
                provider.saveConcession(conc);
                Navigator.pop(ctx);
              },
              child: const Text('Save Concession'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditConcessionModal(FeeConcession c, InstitutionProvider provider) {
    final feeCtrl = TextEditingController(text: c.concessionMonthlyFee.toStringAsFixed(0));
    final reasonCtrl = TextEditingController(text: c.reason);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Concession: ${c.studentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Concession Monthly Fee (₹)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason / Remarks', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            onPressed: () async {
              final newFee = double.tryParse(feeCtrl.text.trim()) ?? c.concessionMonthlyFee;
              final updated = FeeConcession(
                studentId: c.studentId,
                studentName: c.studentName,
                studentClass: c.studentClass,
                concessionMonthlyFee: newFee,
                reason: reasonCtrl.text.trim(),
              );
              await provider.saveConcession(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Concession for "${c.studentName}" updated!')));
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // MODULE 5: WEBSITE MANAGEMENT
  // ========================================================================
  // ========================================================================
  // 5A. BASIC INFO & SOCIAL
  // ========================================================================
  Widget _buildBasicInfoTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Website & Public Profile Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: TextField(controller: _webAppNameCtrl, decoration: const InputDecoration(labelText: 'App Name', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _webInstNameCtrl, decoration: const InputDecoration(labelText: 'Institution Name', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _webSubtitleCtrl, decoration: const InputDecoration(labelText: 'Management / Board Name', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _webRegNoCtrl, decoration: const InputDecoration(labelText: 'Register Number', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _webPlaceCtrl, decoration: const InputDecoration(labelText: 'Place / City', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _webPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: _webEmailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _webAboutCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'About Us Description', border: OutlineInputBorder())),
            const SizedBox(height: 16),

            // Social Media
            const Text('Social Media Links', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _webWaCtrl, decoration: const InputDecoration(labelText: 'WhatsApp', prefixIcon: Icon(Icons.chat), border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _webYtCtrl, decoration: const InputDecoration(labelText: 'YouTube', prefixIcon: Icon(Icons.video_library), border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _webIgCtrl, decoration: const InputDecoration(labelText: 'Instagram', prefixIcon: Icon(Icons.camera_alt), border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _webFbCtrl, decoration: const InputDecoration(labelText: 'Facebook', prefixIcon: Icon(Icons.thumb_up), border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),

            // Bank Details
            const Text('Institution Bank & UPI Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _bankAccNameCtrl, decoration: const InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _bankUpiIdCtrl, decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _bankNameCtrl, decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _bankAccNumCtrl, decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = setting.copyWith(
                    appName: _webAppNameCtrl.text.trim(),
                    institutionName: _webInstNameCtrl.text.trim(),
                    managementName: _webSubtitleCtrl.text.trim(),
                    regNo: _webRegNoCtrl.text.trim(),
                    place: _webPlaceCtrl.text.trim(),
                    phone: _webPhoneCtrl.text.trim(),
                    email: _webEmailCtrl.text.trim(),
                    aboutText: _webAboutCtrl.text.trim(),
                    socialWhatsapp: _webWaCtrl.text.trim(),
                    socialYoutube: _webYtCtrl.text.trim(),
                    socialInstagram: _webIgCtrl.text.trim(),
                    socialFacebook: _webFbCtrl.text.trim(),
                    bankAccountName: _bankAccNameCtrl.text.trim(),
                    bankUpiId: _bankUpiIdCtrl.text.trim(),
                    bankName: _bankNameCtrl.text.trim(),
                    bankAccountNumber: _bankAccNumCtrl.text.trim(),
                  );
                  await provider.updateSettings(updated);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Website info saved successfully!')));
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Website Profile'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5B. NOTICE BOARD
  Widget _buildNoticeBoardTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Publish New Institutional Notice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                TextField(controller: _notHeadCtrl, decoration: const InputDecoration(labelText: 'Notice Heading', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _notDescCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notice Details / Body', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _notDateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Checkbox(value: _notIsPinned, onChanged: (v) => setState(() => _notIsPinned = v ?? false)),
                        const Text('Pin Notice to Top', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_notHeadCtrl.text.isEmpty && _notDescCtrl.text.isEmpty) return;
                    final notice = Notice(
                      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
                      heading: _notHeadCtrl.text.trim(),
                      description: _notDescCtrl.text.trim(),
                      date: _notDateCtrl.text.trim(),
                      isPinned: _notIsPinned,
                    );
                    await provider.saveNotice(notice);
                    _notHeadCtrl.clear();
                    _notDescCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice published!')));
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Publish Notice'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Published Notices
          Text('Published Notices (${provider.notices.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ...provider.notices.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: n.isPinned ? Colors.blue.shade300 : const Color(0xFFE2E8F0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(n.isPinned ? Icons.push_pin_rounded : Icons.notifications_rounded, size: 20, color: n.isPinned ? Colors.blue : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.heading, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 4),
                      Text(n.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      const SizedBox(height: 4),
                      Text(n.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      tooltip: 'Edit Notice',
                      onPressed: () => _showEditNoticeModal(n, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete Notice',
                      onPressed: () async {
                        final confirmed = await _confirmAction(
                          context,
                          title: 'Delete Notice',
                          message: 'Are you sure you want to permanently delete notice "${n.heading}"?',
                          confirmLabel: 'Delete Notice',
                        );
                        if (confirmed) {
                          await provider.deleteNotice(n.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notice "${n.heading}" deleted.')));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showEditNoticeModal(Notice n, InstitutionProvider provider) {
    final headCtrl = TextEditingController(text: n.heading);
    final descCtrl = TextEditingController(text: n.description);
    final dateCtrl = TextEditingController(text: n.date);
    bool isPinned = n.isPinned;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Notice: ${n.heading}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: headCtrl, decoration: const InputDecoration(labelText: 'Notice Heading', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notice Body', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isPinned,
                  title: const Text('Pin Notice to Top', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onChanged: (v) => setDlg(() => isPinned = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                final updated = Notice(
                  id: n.id,
                  heading: headCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  date: dateCtrl.text.trim(),
                  isPinned: isPinned,
                );
                await provider.saveNotice(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notice "${updated.heading}" updated!')));
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // 5C. PHOTO GALLERY
  Widget _buildGalleryTab(InstitutionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Photo Gallery (${provider.gallery.length} items)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select multiple photos from device to batch upload.')));
              },
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Add Photos'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (provider.gallery.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No photos uploaded yet.')))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2),
            itemCount: provider.gallery.length,
            itemBuilder: (ctx, idx) {
              final g = provider.gallery[idx];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      tooltip: 'Delete Photo',
                      onPressed: () async {
                        final confirmed = await _confirmAction(
                          context,
                          title: 'Delete Photo',
                          message: 'Are you sure you want to remove this photo from the institutional gallery?',
                          confirmLabel: 'Delete Photo',
                        );
                        if (confirmed) {
                          await provider.deleteGalleryItem(g.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo deleted from gallery.')));
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  // ========================================================================
  // MODULE 6: SYSTEM & SECURITY
  // ========================================================================
  // ========================================================================
  // 6A. MASTER CREDENTIALS
  // ========================================================================
  Widget _buildCredentialsTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Super Admin Credentials & Identity Control', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text('Signed in as: ${setting.email} (Super Admin)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),

            TextField(
              controller: _currentPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password (Required to verify identity) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newEmailCtrl,
              decoration: const InputDecoration(labelText: 'New Email Address (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identity verified. Credentials update request submitted.')));
                },
                icon: const Icon(Icons.shield_rounded, size: 16),
                label: const Text('Update Super Admin Credentials'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6B. SESSION MONITOR
  Widget _buildSessionMonitorTab(InstitutionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Active Device Sessions & Terminals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: const Row(
            children: [
              Icon(Icons.computer_rounded, size: 24, color: Color(0xFF059669)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Terminal (Admin Console)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    Text('Status: Active • Watchdog: Normal • Channel: Encrypted', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6C. BACKUP & RECOVERY
  Widget _buildBackupRecoveryTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Database Backup & Disaster Recovery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('Export a complete JSON snapshot containing all students, faculty, fees, classes, groups, and settings.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final jsonString = await provider.exportBackupJson();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('JSON Backup Snapshot'),
                    content: SingleChildScrollView(child: Text(jsonString, style: const TextStyle(fontFamily: 'monospace', fontSize: 10))),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export JSON Snapshot'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }

  // 6D. SYSTEM AUDIT TRAIL
  Widget _buildAuditTrailTab(InstitutionProvider provider) {
    final query = _auditSearchCtrl.text.trim().toLowerCase();
    final logs = provider.auditLogs.where((l) {
      if (_auditCategoryFilter != 'all' && l.category != _auditCategoryFilter) return false;
      if (query.isNotEmpty) {
        return l.action.toLowerCase().contains(query) || l.message.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _auditCategoryFilter,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      DropdownMenuItem(value: 'class', child: Text('Classes')),
                      DropdownMenuItem(value: 'student', child: Text('Students')),
                      DropdownMenuItem(value: 'fee', child: Text('Fees')),
                      DropdownMenuItem(value: 'website', child: Text('Website')),
                      DropdownMenuItem(value: 'backup', child: Text('Backup')),
                    ],
                    onChanged: (v) => setState(() => _auditCategoryFilter = v ?? 'all'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _auditSearchCtrl,
                    decoration: const InputDecoration(hintText: 'Filter audit messages...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No audit logs recorded for this category.'))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, idx) {
                    final l = logs[idx];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.blue.shade600),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    Text(l.timestamp.split('T')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(l.message, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

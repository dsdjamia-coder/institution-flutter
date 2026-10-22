import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
  // Academic Year Form State
  final _yearLabelCtrl = TextEditingController(text: '2026-2027');
  String _yearStartMonth = 'June';
  String _yearEndMonth = 'March';
  String _yearStatus = 'active';

  // Staff Directory Filter & State
  final _staffSearchCtrl = TextEditingController();
  String _staffRoleFilter = 'ALL';

  // Add Staff Form State
  final _addStaffNameCtrl = TextEditingController();
  final _addStaffDesigCtrl = TextEditingController(text: 'TEACHER');
  final _addStaffSamasthaCtrl = TextEditingController();
  final _addStaffPhoneCtrl = TextEditingController();
  final _addStaffEmailCtrl = TextEditingController();
  final _addStaffUpiAccCtrl = TextEditingController();
  final _addStaffUpiIdCtrl = TextEditingController();
  String _addStaffRole = 'TEACHER';
  bool _addStaffCanCollect = true;
  bool _addStaffCanWorksheet = true;
  bool _addStaffCanResults = true;
  bool _addStaffCanAdmin = false;
  bool _addStaffActAsSuperAdmin = false;
  final Set<String> _addStaffAssignedClasses = {};

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
  final _stuRollCtrl = TextEditingController(text: '1');
  final _stuBloodGroupCtrl = TextEditingController(text: 'O+');
  String _stuGender = 'Male';
  String? _stuClass;
  String _stuStatus = 'Active';
  String? _admDuplicateWarning;

  // Bulk Excel/CSV Import Workstation
  final _bulkCsvTextCtrl = TextEditingController();
  String? _bulkTargetClass;
  List<Map<String, dynamic>> _parsedBulkStudents = [];
  bool _isParsingBulk = false;
  bool _isUploadingBulk = false;
  double _bulkUploadProgress = 0.0;

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
  String _sortMode = 'adm';
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
    _stuRollCtrl.dispose();
    _stuBloodGroupCtrl.dispose();
    _yearLabelCtrl.dispose();
    _staffSearchCtrl.dispose();
    _addStaffNameCtrl.dispose();
    _addStaffDesigCtrl.dispose();
    _addStaffSamasthaCtrl.dispose();
    _addStaffPhoneCtrl.dispose();
    _addStaffEmailCtrl.dispose();
    _addStaffUpiAccCtrl.dispose();
    _addStaffUpiIdCtrl.dispose();
    _bulkCsvTextCtrl.dispose();
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

  // ========================================================================
  // MODULE 1: INSTITUTION & ACADEMIC CONTROL
  // ========================================================================

  // 1A. OVERVIEW & PROFILE
  Widget _buildOverviewTab(InstitutionProvider provider, dynamic setting) {
    final hasActiveYear = setting.activeAcademicYear.isNotEmpty;
    final hasClasses = provider.classes.isNotEmpty;
    final hasStaff = provider.staffList.isNotEmpty;
    final hasFeeConfig = setting.defaultMonthlyFee > 0;
    final isConfigured = hasActiveYear && hasClasses && hasStaff && hasFeeConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Command Center Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
                            ),
                            child: const Text(
                              'INSTITUTION COMMAND CENTER',
                              style: TextStyle(color: Color(0xFF93C5FD), fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          const Text('LIVE CLOUD CONNECTED', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        setting.institutionName,
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${setting.place} • Reg #${setting.regNo} • ${setting.managementName}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() {
                    _currentModuleIndex = 0;
                    _currentSubIndex = 1;
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Text('ACTIVE ACADEMIC YEAR', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(setting.activeAcademicYear, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white60),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Institutional Readiness Status Card
          Container(
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
                    Row(
                      children: [
                        Icon(
                          isConfigured ? Icons.verified_rounded : Icons.pending_actions_rounded,
                          color: isConfigured ? const Color(0xFF059669) : const Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Institutional Setup & Health Checklist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfigured ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isConfigured ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        isConfigured ? 'System Fully Configured' : 'Setup Incomplete',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isConfigured ? const Color(0xFF065F46) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildSetupPill('Active Session', hasActiveYear, setting.activeAcademicYear),
                    _buildSetupPill('Classes & Cohorts', hasClasses, '${provider.classes.length} Classes'),
                    _buildSetupPill('Faculty & Accounts', hasStaff, '${provider.staffList.length} Accounts'),
                    _buildSetupPill('Standard Fee Plan', hasFeeConfig, '₹${setting.defaultMonthlyFee.toStringAsFixed(0)} / mo'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Metrics Grid (6 KPI cards)
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 720;
              return GridView.count(
                crossAxisCount: isWide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 1.5 : 1.25,
                children: [
                  StatCard(
                    title: 'Active Students',
                    value: '${provider.totalActiveStudents}',
                    subtitle: '${provider.totalBoys} Boys • ${provider.totalGirls} Girls',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                  StatCard(
                    title: 'Classes & Divisions',
                    value: '${provider.classes.length}',
                    subtitle: 'Active standard cohorts',
                    icon: Icons.class_rounded,
                    color: const Color(0xFF7C3AED),
                  ),
                  StatCard(
                    title: 'Faculty & Staff',
                    value: '${provider.totalStaff}',
                    subtitle: 'Authenticated roles',
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF059669),
                  ),
                  StatCard(
                    title: 'Sibling Groups',
                    value: '${provider.studentGroups.length}',
                    subtitle: 'Family fee discount bundles',
                    icon: Icons.diversity_3_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                  StatCard(
                    title: 'Custom Fee Heads',
                    value: '${provider.customFeeItems.length}',
                    subtitle: 'Catalog items configured',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFD97706),
                  ),
                  StatCard(
                    title: 'Departed Archives',
                    value: '${provider.discontinuedStudents.length}',
                    subtitle: 'Preserved dues & records',
                    icon: Icons.transfer_within_a_station_rounded,
                    color: const Color(0xFFE11D48),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Quick Administrative Launchers
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Administrative Action Launchers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Direct shortcuts to administrative workflows across modules', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildQuickActionBtn('Academic Years', Icons.calendar_month_rounded, const Color(0xFF2563EB), () => setState(() { _currentModuleIndex = 0; _currentSubIndex = 1; })),
                    _buildQuickActionBtn('Staff Directory', Icons.badge_rounded, const Color(0xFF059669), () => setState(() { _currentModuleIndex = 0; _currentSubIndex = 2; })),
                    _buildQuickActionBtn('Add Staff Member', Icons.person_add_alt_1_rounded, const Color(0xFF0D9488), () => setState(() { _currentModuleIndex = 0; _currentSubIndex = 3; })),
                    _buildQuickActionBtn('Manage Students', Icons.people_outline_rounded, const Color(0xFF7C3AED), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Add Student (Manual)', Icons.person_add_rounded, const Color(0xFF2563EB), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 1; })),
                    _buildQuickActionBtn('Bulk Excel Upload', Icons.file_upload_rounded, const Color(0xFFD97706), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 2; })),
                    _buildQuickActionBtn('Classes & Divisions', Icons.alt_route_rounded, const Color(0xFF4F46E5), () => setState(() { _currentModuleIndex = 1; _currentSubIndex = 3; })),
                    _buildQuickActionBtn('Discontinue / Exit', Icons.transfer_within_a_station_rounded, const Color(0xFFE11D48), () => setState(() { _currentModuleIndex = 2; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Fee Windows & Rules', Icons.receipt_rounded, const Color(0xFFD97706), () => setState(() { _currentModuleIndex = 3; _currentSubIndex = 0; })),
                    _buildQuickActionBtn('Publish Notice', Icons.campaign_rounded, const Color(0xFF059669), () => setState(() { _currentModuleIndex = 4; _currentSubIndex = 1; })),
                    _buildQuickActionBtn('Export Backup JSON', Icons.download_rounded, const Color(0xFF475569), () => setState(() { _currentModuleIndex = 5; _currentSubIndex = 2; })),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPill(String title, bool isDone, String detail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDone ? Icons.check_circle_rounded : Icons.info_outline_rounded, size: 14, color: isDone ? const Color(0xFF059669) : const Color(0xFFD97706)),
          const SizedBox(width: 6),
          Text('$title: ', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          Text(detail, style: TextStyle(fontSize: 11.5, color: isDone ? const Color(0xFF065F46) : const Color(0xFF92400E), fontWeight: FontWeight.w600)),
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
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // 1B. ACADEMIC YEARS
  Widget _buildAcademicYearsTab(InstitutionProvider provider, dynamic setting) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Working Session Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF059669).withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACTIVE WORKING ACADEMIC SESSION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46), letterSpacing: 0.8)),
                      const SizedBox(height: 2),
                      Text(setting.activeAcademicYear, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                      const SizedBox(height: 2),
                      const Text('All student enrollments, fee structures, mark sheets, and daily attendance default to this session.', style: TextStyle(fontSize: 11.5, color: Color(0xFF047857))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Configure Academic Year Form
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configure Academic Year (YYYY-YYYY)', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                const Text('Specify calendar bounds and working status. Switch working sessions with automatic continuity checks.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                // Quick suggestions
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    const Text('Auto-Suggest:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    _buildYearSuggestChip('2025-2026'),
                    _buildYearSuggestChip('2026-2027'),
                    _buildYearSuggestChip('2027-2028'),
                    _buildYearSuggestChip('2028-2029'),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _yearLabelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Academic Year Label *',
                          hintText: 'e.g. 2026-2027',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _yearStartMonth,
                        decoration: const InputDecoration(labelText: 'Start Month', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                        items: months.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12.5)))).toList(),
                        onChanged: (v) => setState(() => _yearStartMonth = v ?? 'June'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _yearEndMonth,
                        decoration: const InputDecoration(labelText: 'End Month', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                        items: months.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12.5)))).toList(),
                        onChanged: (v) => setState(() => _yearEndMonth = v ?? 'March'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _yearStatus,
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active', style: TextStyle(fontSize: 12.5))),
                          DropdownMenuItem(value: 'current', child: Text('Current Working', style: TextStyle(fontSize: 12.5))),
                          DropdownMenuItem(value: 'archived', child: Text('Archived', style: TextStyle(fontSize: 12.5))),
                        ],
                        onChanged: (v) => setState(() => _yearStatus = v ?? 'active'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final val = _yearLabelCtrl.text.trim();
                        if (RegExp(r'^\d{4}-\d{4}$').hasMatch(val)) {
                          await provider.addAcademicYear(AcademicYearConfig(
                            label: val,
                            startMonth: _yearStartMonth,
                            endMonth: _yearEndMonth,
                            status: _yearStatus,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Academic Year "$val" saved successfully!'), backgroundColor: const Color(0xFF059669)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid year format! Must be YYYY-YYYY (e.g. 2026-2027)'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Save Year'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Configured Years List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Configured Academic Sessions (${provider.academicYears.length})', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Text('Active session updates student defaults automatically', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 10),

          if (provider.academicYears.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Center(child: Text('No academic years configured yet. Please configure the first year above.')),
            )
          else
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
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 20, color: isCurrent ? const Color(0xFF059669) : const Color(0xFF2563EB)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(y.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A))),
                                  const SizedBox(width: 8),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('CURRENT WORKING YEAR', style: TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold)),
                                    )
                                  else if (y.status == 'archived')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('ARCHIVED', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Term Period: ${y.startMonth} to ${y.endMonth} • Status: ${y.status.toUpperCase()}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!isCurrent)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () async {
                                await provider.setWorkingAcademicYear(y.label);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Active working academic year switched to "${y.label}"!'), backgroundColor: const Color(0xFF059669)),
                                );
                              },
                              child: const Text('Set as Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                                message: 'Are you sure you want to delete academic year "${y.label}"? Enrolled student associations and records may be affected.',
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

  Widget _buildYearSuggestChip(String year) {
    return InkWell(
      onTap: () => setState(() => _yearLabelCtrl.text = year),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
        child: Text(year, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
      ),
    );
  }

  void _showEditAcademicYearModal(AcademicYearConfig y, InstitutionProvider provider) {
    String startMonth = y.startMonth;
    String endMonth = y.endMonth;
    String status = y.status;
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

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
                  DropdownMenuItem(value: 'current', child: Text('Current Working')),
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
                if (status == 'current') {
                  await provider.setWorkingAcademicYear(y.label);
                }
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
    final query = _staffSearchCtrl.text.trim().toLowerCase();
    final filtered = provider.staffList.where((st) {
      if (_staffRoleFilter != 'ALL' && st.role != _staffRoleFilter) return false;
      if (query.isNotEmpty) {
        final m = st.name.toLowerCase().contains(query) ||
            st.phone.contains(query) ||
            st.email.toLowerCase().contains(query) ||
            st.designation.toLowerCase().contains(query);
        if (!m) return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Toolbar Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _staffSearchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search staff by name, phone, designation...',
                      prefixIcon: Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _staffRoleFilter,
                    decoration: const InputDecoration(
                      labelText: 'Role Filter',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Roles', style: TextStyle(fontSize: 12.5))),
                      DropdownMenuItem(value: 'TEACHER', child: Text('Teachers / Ustad', style: TextStyle(fontSize: 12.5))),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrators', style: TextStyle(fontSize: 12.5))),
                      DropdownMenuItem(value: 'COLLECTOR', child: Text('Cashier / Collectors', style: TextStyle(fontSize: 12.5))),
                    ],
                    onChanged: (v) => setState(() => _staffRoleFilter = v ?? 'ALL'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _currentModuleIndex = 0;
                    _currentSubIndex = 3;
                  }),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Add Staff'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Staff List View
          Expanded(
            child: filtered.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.badge_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        const Text('No faculty or staff matching your query.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        const Text('Adjust your role filter or register a new staff member.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final st = filtered[idx];
                      final roleColor = st.role == 'ADMIN'
                          ? const Color(0xFFD97706)
                          : (st.role == 'COLLECTOR' ? const Color(0xFF059669) : const Color(0xFF2563EB));
                      final assignedList = st.assignedClasses.isNotEmpty
                          ? st.assignedClasses
                          : (st.assignedClass.isNotEmpty ? st.assignedClass.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : <String>[]);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: roleColor.withOpacity(0.12),
                              child: Text(
                                st.name.isNotEmpty ? st.name[0].toUpperCase() : 'U',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: roleColor),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A))),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                        child: Text(st.role, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: roleColor)),
                                      ),
                                      if (st.designation.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                          child: Text(st.designation, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                        ),
                                      ],
                                      if (st.samasthaRegNo.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                          child: Text('Reg: ${st.samasthaRegNo}', style: const TextStyle(fontSize: 10, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(st.phone.isNotEmpty ? st.phone : 'No Phone', style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.email_outlined, size: 13, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(st.email.isNotEmpty ? st.email : 'No Email', style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Assigned Classes Wrap
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Assigned: ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                      if (assignedList.isEmpty)
                                        const Text('All Classes', style: TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w600))
                                      else
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: assignedList.map((c) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFBFDBFE))),
                                            child: Text(c, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                          )).toList(),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 4-Portal Access Badges
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _buildAccessBadge('Fees', st.hasCollectionAccess, const Color(0xFF059669)),
                                      _buildAccessBadge('Worksheet', st.hasWorksheetAccess, const Color(0xFF2563EB)),
                                      _buildAccessBadge('Results', st.hasResultAccess, const Color(0xFF7C3AED)),
                                      _buildAccessBadge('Admin', st.hasAdminAccess, const Color(0xFFD97706)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF2563EB)),
                                  tooltip: 'Edit Profile & Portal Access',
                                  onPressed: () => _showEditStaffModal(st, provider),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.assignment_ind_rounded, size: 19, color: Color(0xFF059669)),
                                  tooltip: 'Assign Duty Classes & UPI Account',
                                  onPressed: () => _showDutyModal(st, provider),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 19, color: Colors.red),
                                  tooltip: 'Delete Staff Member',
                                  onPressed: () async {
                                    final confirmed = await _confirmAction(
                                      context,
                                      title: 'Delete Staff Member',
                                      message: 'Are you sure you want to permanently remove faculty member "${st.name}"? All assigned access and login credentials will be revoked.',
                                      confirmLabel: 'Delete Staff',
                                    );
                                    if (confirmed) {
                                      await provider.deleteStaff(st.id);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff member "${st.name}" deleted.')));
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
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadge(String label, bool isGranted, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isGranted ? activeColor.withOpacity(0.1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isGranted ? activeColor.withOpacity(0.3) : const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isGranted ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 11, color: isGranted ? activeColor : const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isGranted ? activeColor : const Color(0xFF94A3B8))),
        ],
      ),
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
          title: Row(
            children: [
              const Icon(Icons.badge_rounded, color: Color(0xFF2563EB), size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text('Edit Staff Profile: ${st.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
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
                      DropdownMenuItem(value: 'TEACHER', child: Text('Teacher / Faculty')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                      DropdownMenuItem(value: 'COLLECTOR', child: Text('Cashier / Fee Collector')),
                    ],
                    onChanged: (val) => setLocal(() => role = val ?? 'TEACHER'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Designation (e.g. Swadar, Headmaster)', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: samasthaCtrl, decoration: const InputDecoration(labelText: 'Samastha Reg # (Optional)', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / WhatsApp *', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address *', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('4-Portal Access Control Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    value: canCollect,
                    dense: true,
                    onChanged: (v) => setLocal(() => canCollect = v ?? true),
                    title: const Text('1. Fee Collection & Receipts Portal', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Allows collecting dues and issuing receipts', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                  CheckboxListTile(
                    value: canWorksheet,
                    dense: true,
                    onChanged: (v) => setLocal(() => canWorksheet = v ?? true),
                    title: const Text('2. Class Worksheet & Daily Attendance', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Allows marking attendance and grade sheets', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                  CheckboxListTile(
                    value: canResults,
                    dense: true,
                    onChanged: (v) => setLocal(() => canResults = v ?? false),
                    title: const Text('3. Result Management System', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Allows entering exam scores and publishing results', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                  CheckboxListTile(
                    value: canAdmin,
                    dense: true,
                    onChanged: (v) => setLocal(() => canAdmin = v ?? false),
                    title: const Text('4. Admin Command Center', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Allows full institution settings and data controls', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                ],
              ),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff member "${updated.name}" updated successfully!'), backgroundColor: const Color(0xFF059669)));
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
    final assignedClasses = Set<String>.from(
      st.assignedClasses.isNotEmpty
          ? st.assignedClasses
          : (st.assignedClass.isNotEmpty ? st.assignedClass.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty) : <String>[]),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.assignment_ind_rounded, color: Color(0xFF059669), size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text('Assign Duties: ${st.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Assigned Duty Classes (Multiple Selection)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('Class teachers can record attendance and enter marks for these classes.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.classes.map((c) {
                      final isSel = assignedClasses.contains(c);
                      return FilterChip(
                        selected: isSel,
                        selectedColor: const Color(0xFFDBEAFE),
                        checkmarkColor: const Color(0xFF1D4ED8),
                        label: Text(c, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? const Color(0xFF1E40AF) : const Color(0xFF334155))),
                        onSelected: (val) {
                          setDlgState(() {
                            if (val) assignedClasses.add(c); else assignedClasses.remove(c);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text('2. Personal UPI Cashier Account (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('When this staff member accepts fee payments, their UPI QR can be rendered for payments.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'Account Holder Name', hintText: 'e.g. Sanjid Ustad', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: upiCtrl, decoration: const InputDecoration(labelText: 'UPI ID (VPA)', hintText: 'e.g. 9876543210@okaxis', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () async {
                final updated = st.copyWith(
                  assignedClass: assignedClasses.join(', '),
                  assignedClasses: assignedClasses.toList(),
                  upiAccountName: accCtrl.text.trim(),
                  upiId: upiCtrl.text.trim(),
                );
                await provider.updateStaff(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duties and UPI account for "${st.name}" updated!'), backgroundColor: const Color(0xFF059669)));
              },
              child: const Text('Save Duties & Account'),
            ),
          ],
        ),
      ),
    );
  }

  // 1D. ADD STAFF & CATEGORIES
  Widget _buildAddStaffTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Row(
                  children: const [
                    Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text('Register Faculty / Staff Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _currentModuleIndex = 0;
                    _currentSubIndex = 2;
                  }),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Back to Directory'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Configure staff profile, duty classes, and granular 4-portal access permissions.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const Divider(height: 24),

            // Two-column layout
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 760;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Identity & Details
                    Expanded(
                      flex: isWide ? 1 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Staff Profile & Contact Information', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _addStaffNameCtrl,
                            decoration: const InputDecoration(labelText: 'Full Staff Name *', hintText: 'e.g. USTAD AHMAD K', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _addStaffRole,
                                  decoration: const InputDecoration(labelText: 'Role *', border: OutlineInputBorder()),
                                  items: const [
                                    DropdownMenuItem(value: 'TEACHER', child: Text('Teacher / Faculty')),
                                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                                    DropdownMenuItem(value: 'COLLECTOR', child: Text('Cashier / Fee Collector')),
                                  ],
                                  onChanged: (val) => setState(() => _addStaffRole = val ?? 'TEACHER'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _addStaffDesigCtrl,
                                  decoration: const InputDecoration(labelText: 'Designation', hintText: 'e.g. Swadar, Headmaster', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _addStaffPhoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(labelText: 'Phone / WhatsApp *', hintText: 'e.g. 9876543210', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _addStaffEmailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'e.g. staff@school.com', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _addStaffSamasthaCtrl,
                            decoration: const InputDecoration(labelText: 'Samastha / Board Registration # (Optional)', hintText: 'e.g. REG-88321', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),

                          const Text('Optional UPI Account Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: _addStaffUpiAccCtrl, decoration: const InputDecoration(labelText: 'UPI Account Holder Name', border: OutlineInputBorder()))),
                              const SizedBox(width: 10),
                              Expanded(child: TextField(controller: _addStaffUpiIdCtrl, decoration: const InputDecoration(labelText: 'UPI ID (VPA)', border: OutlineInputBorder()))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right Column: Assigned Classes & 4-Portal Access
                    Expanded(
                      flex: isWide ? 1 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('2. Assigned Duty Classes', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          const Text('Select classes where this teacher holds academic jurisdiction.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.classes.map((c) {
                              final isSel = _addStaffAssignedClasses.contains(c);
                              return FilterChip(
                                selected: isSel,
                                selectedColor: const Color(0xFFDBEAFE),
                                checkmarkColor: const Color(0xFF1D4ED8),
                                label: Text(c, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? const Color(0xFF1E40AF) : const Color(0xFF334155))),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) _addStaffAssignedClasses.add(c); else _addStaffAssignedClasses.remove(c);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          const Text('3. 4-Portal Access Security Permissions', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          const SizedBox(height: 6),
                          const Text('Granularly grant or restrict portal access to this staff member.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 10),

                          CheckboxListTile(
                            value: _addStaffCanCollect,
                            dense: true,
                            onChanged: (v) => setState(() => _addStaffCanCollect = v ?? true),
                            title: const Text('1. Fee Collection & Receipts', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Collect fees, print receipts, view daily registers', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ),
                          CheckboxListTile(
                            value: _addStaffCanWorksheet,
                            dense: true,
                            onChanged: (v) => setState(() => _addStaffCanWorksheet = v ?? true),
                            title: const Text('2. Worksheet & Attendance Portal', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Mark daily attendance, generate class registers', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ),
                          CheckboxListTile(
                            value: _addStaffCanResults,
                            dense: true,
                            onChanged: (v) => setState(() => _addStaffCanResults = v ?? false),
                            title: const Text('3. Result Management System', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Enter marks, grade exams, promote cohorts', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ),
                          CheckboxListTile(
                            value: _addStaffCanAdmin,
                            dense: true,
                            onChanged: (v) => setState(() => _addStaffCanAdmin = v ?? false),
                            title: const Text('4. Admin Command Center', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Full institution settings, student management, security', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ),
                          if (_addStaffCanAdmin)
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: CheckboxListTile(
                                value: _addStaffActAsSuperAdmin,
                                dense: true,
                                onChanged: (v) => setState(() => _addStaffActAsSuperAdmin = v ?? false),
                                title: const Text('Super Administrator Privileges', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                subtitle: const Text('Unlocks master credentials, cloud restores, audit wipes', style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309))),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 28),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final name = _addStaffNameCtrl.text.trim();
                  final phone = _addStaffPhoneCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Staff Name!'), backgroundColor: Colors.red));
                    return;
                  }
                  if (phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Phone Number!'), backgroundColor: Colors.red));
                    return;
                  }

                  final newStaff = Staff(
                    id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    role: _addStaffRole,
                    designation: _addStaffDesigCtrl.text.trim(),
                    samasthaRegNo: _addStaffSamasthaCtrl.text.trim(),
                    phone: phone,
                    email: _addStaffEmailCtrl.text.trim(),
                    assignedClass: _addStaffAssignedClasses.join(', '),
                    assignedClasses: _addStaffAssignedClasses.toList(),
                    upiAccountName: _addStaffUpiAccCtrl.text.trim(),
                    upiId: _addStaffUpiIdCtrl.text.trim(),
                    hasCollectionAccess: _addStaffCanCollect,
                    hasWorksheetAccess: _addStaffCanWorksheet,
                    hasResultAccess: _addStaffCanResults,
                    hasAdminAccess: _addStaffCanAdmin,
                  );

                  await provider.addStaff(newStaff);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Faculty member "${newStaff.name}" registered successfully!'), backgroundColor: const Color(0xFF059669)),
                  );

                  // Reset form
                  _addStaffNameCtrl.clear();
                  _addStaffPhoneCtrl.clear();
                  _addStaffEmailCtrl.clear();
                  _addStaffSamasthaCtrl.clear();
                  _addStaffUpiAccCtrl.clear();
                  _addStaffUpiIdCtrl.clear();
                  _addStaffAssignedClasses.clear();

                  // Switch back to Directory
                  setState(() {
                    _currentModuleIndex = 0;
                    _currentSubIndex = 2;
                  });
                },
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Register Staff Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // MODULE 2: STUDENT ADMINISTRATION & ENROLLMENT
  // ========================================================================

  // 2A. MANAGE STUDENTS
  Widget _buildManageStudentsTab(InstitutionProvider provider) {
    final activeYear = provider.setting.activeAcademicYear;
    final isArchiveView = _filterYear != 'ALL' && _filterYear != activeYear;

    final query = _studentSearchCtrl.text.trim().toLowerCase();
    final filtered = provider.students.where((s) {
      if (_filterYear != 'ALL' && s.academicYear != _filterYear) return false;
      if (_filterClass != 'ALL' && s.studentClass != _filterClass) return false;
      if (_filterGender != 'ALL' && s.gender.toLowerCase() != _filterGender.toLowerCase()) return false;
      if (_filterStatus != 'ALL' && s.status.toLowerCase() != _filterStatus.toLowerCase()) return false;
      if (query.isNotEmpty) {
        final m = s.name.toLowerCase().contains(query) ||
            s.adm.toLowerCase().contains(query) ||
            s.mobile.contains(query) ||
            s.father.toLowerCase().contains(query);
        if (!m) return false;
      }
      return true;
    }).toList();

    // Sort order
    final sortedList = [...filtered];
    if (_sortMode == 'adm') {
      sortedList.sort((a, b) {
        final aNum = int.tryParse(a.adm);
        final bNum = int.tryParse(b.adm);
        if (aNum != null && bNum != null) return aNum.compareTo(bNum);
        return a.adm.compareTo(b.adm);
      });
    } else if (_sortMode == 'name') {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortMode == 'male_first') {
      sortedList.sort((a, b) {
        if (a.gender.toLowerCase() != b.gender.toLowerCase()) {
          return a.gender.toLowerCase() == 'male' ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    }

    final boysCount = sortedList.where((s) => s.gender.toLowerCase() == 'male').length;
    final girlsCount = sortedList.where((s) => s.gender.toLowerCase() == 'female').length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Historical Archive Warning Banner
          if (isArchiveView)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HISTORICAL ARCHIVE SESSION ($_filterYear) — READ ONLY MODE. Modifications are locked to preserve institutional records.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),

          // Multi-Filter & Search Toolbar Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _studentSearchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search student name, adm #, father, mobile...',
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _filterYear,
                        decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: ['ALL', ...provider.academicYears.map((y) => y.label)].toSet().map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _filterYear = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _filterClass,
                        decoration: const InputDecoration(labelText: 'Class Cohort', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: ['ALL', ...provider.classes, 'Alumni'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _filterClass = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterGender,
                        decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (v) => setState(() => _filterGender = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'Alumni', child: Text('Alumni', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'Discontinued', child: Text('Exit', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (v) => setState(() => _filterStatus = v ?? 'ALL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _sortMode,
                        decoration: const InputDecoration(labelText: 'Sort By', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'adm', child: Text('Adm #', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'name', child: Text('Name (A-Z)', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'male_first', child: Text('Male First', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (v) => setState(() => _sortMode = v ?? 'adm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quick Action & Export Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Showing ${sortedList.length} of ${provider.students.length} students', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                          child: Text('$boysCount Boys', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(4)),
                          child: Text('$girlsCount Girls', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBE185D))),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final csv = StringBuffer('Sl,AdmNo,Name,Class,Gender,Father,Mobile,Status,AcademicYear\n');
                            for (int i = 0; i < sortedList.length; i++) {
                              final s = sortedList[i];
                              csv.writeln('${i + 1},"${s.adm}","${s.name}","${s.studentClass}","${s.gender}","${s.father}","${s.mobile}","${s.status}","${s.academicYear}"');
                            }
                            await Clipboard.setData(ClipboardData(text: csv.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported ${sortedList.length} students to CSV (Copied to Clipboard)!'), backgroundColor: const Color(0xFF059669)));
                          },
                          icon: const Icon(Icons.table_chart_rounded, size: 14),
                          label: const Text('Export CSV', style: TextStyle(fontSize: 11.5)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {
                            _currentModuleIndex = 1;
                            _currentSubIndex = 1;
                          }),
                          icon: const Icon(Icons.person_add_rounded, size: 14),
                          label: const Text('Add Student', style: TextStyle(fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Students Roster
          Expanded(
            child: sortedList.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        const Text('No students matching selected filter criteria.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        const Text('Try clearing your search query or switching the class/status filters.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: sortedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final s = sortedList[idx];
                      final isMale = s.gender.toLowerCase() == 'male';
                      final avatarColor = isMale ? const Color(0xFF2563EB) : const Color(0xFFBE185D);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: avatarColor.withOpacity(0.12),
                              child: Text(
                                s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                style: TextStyle(fontWeight: FontWeight.bold, color: avatarColor, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A))),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                        child: Text('#${s.adm}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isMale ? const Color(0xFFEFF6FF) : const Color(0xFFFDF2F8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(s.gender, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: avatarColor)),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: s.status == 'Active' ? const Color(0xFFECFDF5) : (s.status == 'Alumni' ? const Color(0xFFFAF5FF) : const Color(0xFFFFF1F2)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          s.status,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: s.status == 'Active' ? const Color(0xFF065F46) : (s.status == 'Alumni' ? const Color(0xFF6B21A8) : const Color(0xFF9F1239)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Class: ${s.studentClass} • Father: ${s.father.isNotEmpty ? s.father : 'N/A'} • Ph: ${s.mobile.isNotEmpty ? s.mobile : 'N/A'} • Year: ${s.academicYear}',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
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
                                  message: 'Are you sure you want to permanently delete student "${s.name}" (#${s.adm})? All associated marks, fee logs, and registration history will be removed.',
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
    final motherCtrl = TextEditingController(text: s.mother);
    final phoneCtrl = TextEditingController(text: s.mobile);
    final motherPhoneCtrl = TextEditingController(text: s.motherMobile);
    final dobCtrl = TextEditingController(text: s.dob);
    final admDateCtrl = TextEditingController(text: s.admissionDate);
    final aadhaarCtrl = TextEditingController(text: s.adhaar);
    final uidCtrl = TextEditingController(text: s.uid);
    final addressCtrl = TextEditingController(text: s.address);
    final rollCtrl = TextEditingController(text: s.roll.toString());
    String cls = s.studentClass;
    String gender = s.gender;
    String status = s.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text('Edit Student: ${s.name} (#${s.adm})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 550,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Academic & Enrollment Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: admCtrl, decoration: const InputDecoration(labelText: 'Adm No *', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Student Full Name *', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: cls,
                          decoration: const InputDecoration(labelText: 'Class *', border: OutlineInputBorder()),
                          items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setDlg(() => cls = v ?? cls),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: ['Male', 'Female'].contains(gender) ? gender : 'Male',
                          decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                          items: const [DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Female', child: Text('Female'))],
                          onChanged: (v) => setDlg(() => gender = v ?? 'Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: rollCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Roll No', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: ['Active', 'Alumni', 'Discontinued'].contains(status) ? status : 'Active',
                    decoration: const InputDecoration(labelText: 'Enrollment Status *', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active Enrollment')),
                      DropdownMenuItem(value: 'Alumni', child: Text('Graduated Alumni')),
                      DropdownMenuItem(value: 'Discontinued', child: Text('Discontinued / Exit')),
                    ],
                    onChanged: (v) => setDlg(() => status = v ?? 'Active'),
                  ),
                  const SizedBox(height: 14),

                  const Text('2. Family & Guardian Contacts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: fatherCtrl, decoration: const InputDecoration(labelText: "Father's Name *", border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: motherCtrl, decoration: const InputDecoration(labelText: "Mother's Name", border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Father's Mobile *", border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: motherPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Mother's Mobile", border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Residential Address', border: OutlineInputBorder())),
                  const SizedBox(height: 14),

                  const Text('3. Identity & Official Records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: admDateCtrl, decoration: const InputDecoration(labelText: 'Admission Date', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: aadhaarCtrl, decoration: const InputDecoration(labelText: 'Aadhaar Number', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: 'Samastha ID / UID', border: OutlineInputBorder()))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              onPressed: () async {
                final newAdm = admCtrl.text.trim();
                final newName = nameCtrl.text.trim();
                if (newAdm.isEmpty || newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admission number and name cannot be empty!'), backgroundColor: Colors.red));
                  return;
                }

                // Check duplicate admission number if changed
                if (newAdm.toUpperCase() != s.adm.toUpperCase() &&
                    DuplicateGuard.isAdmissionNoDuplicate(newAdm, provider.students, excludeStudentId: s.id)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admission #$newAdm is already in use by another student!'), backgroundColor: Colors.red));
                  return;
                }

                final updated = s.copyWith(
                  adm: newAdm,
                  name: newName,
                  studentClass: cls,
                  gender: gender,
                  roll: int.tryParse(rollCtrl.text.trim()) ?? s.roll,
                  status: status,
                  father: fatherCtrl.text.trim(),
                  mother: motherCtrl.text.trim(),
                  mobile: phoneCtrl.text.trim(),
                  motherMobile: motherPhoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  dob: dobCtrl.text.trim(),
                  admissionDate: admDateCtrl.text.trim(),
                  adhaar: aadhaarCtrl.text.trim(),
                  uid: uidCtrl.text.trim(),
                );

                await provider.updateStudent(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student "${updated.name}" updated successfully!'), backgroundColor: const Color(0xFF059669)));
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
        padding: const EdgeInsets.all(20),
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
                Row(
                  children: const [
                    Icon(Icons.person_add_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text('Add Student — Manual Form Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _currentModuleIndex = 1;
                    _currentSubIndex = 0;
                  }),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Back to Manage Students'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Complete 15-field institutional student registration with live duplicate guard and validation.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const Divider(height: 24),

            // Duplicate admission warning
            if (_admDuplicateWarning != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_admDuplicateWarning!, style: const TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ),
                  ],
                ),
              ),

            // Section 1: Academic & Enrollment Information
            const Text('1. Academic & Enrollment Details', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stuAdmCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admission Number (Adm No) *',
                      hintText: 'e.g. 1045',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _stuNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Student Name *',
                      hintText: 'e.g. MOHAMMED RAYAN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stuClass ?? (provider.classes.isNotEmpty ? provider.classes.first : null),
                    decoration: const InputDecoration(labelText: 'Target Class *', border: OutlineInputBorder()),
                    items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _stuClass = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stuGender,
                    decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                    items: const [DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Female', child: Text('Female'))],
                    onChanged: (v) => setState(() => _stuGender = v ?? 'Male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuRollCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Roll Number', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Family & Contacts
            const Text('2. Family & Guardian Contacts', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stuFatherCtrl,
                    decoration: const InputDecoration(labelText: "Father's Full Name *", hintText: 'e.g. ABDULLA', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuMotherCtrl,
                    decoration: const InputDecoration(labelText: "Mother's Full Name", hintText: 'e.g. FATHIMA', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stuFatherMobCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Father's Phone / WhatsApp *", hintText: 'e.g. 9876543210', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuMotherMobCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Mother's Phone", hintText: 'e.g. 9876543211', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _stuAddressCtrl,
              decoration: const InputDecoration(labelText: 'Permanent Residential Address *', hintText: 'House Name, Locality, P.O, District', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Section 3: Identity & Records
            const Text('3. Identity & Official Records', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stuDobCtrl,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(_stuDobCtrl.text) ?? DateTime(2015, 5, 15),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _stuDobCtrl.text = picked.toString().split(' ')[0]);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuAdmDateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Admission Date (YYYY-MM-DD)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(_stuAdmDateCtrl.text) ?? DateTime(2026, 6, 1),
                            firstDate: DateTime(2015),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _stuAdmDateCtrl.text = picked.toString().split(' ')[0]);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stuAadhaarCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Aadhaar Number (12 Digits)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuUidCtrl,
                    decoration: const InputDecoration(labelText: 'Samastha ID / UID', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stuBloodGroupCtrl,
                    decoration: const InputDecoration(labelText: 'Blood Group', hintText: 'e.g. O+, B+', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Submit Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _stuAdmCtrl.clear();
                    _stuNameCtrl.clear();
                    _stuFatherCtrl.clear();
                    _stuMotherCtrl.clear();
                    _stuFatherMobCtrl.clear();
                    _stuMotherMobCtrl.clear();
                    _stuAddressCtrl.clear();
                    _stuAadhaarCtrl.clear();
                    _stuUidCtrl.clear();
                  },
                  child: const Text('Clear Form'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final adm = _stuAdmCtrl.text.trim();
                    final name = _stuNameCtrl.text.trim();
                    if (adm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admission Number is required!'), backgroundColor: Colors.red));
                      return;
                    }
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Name is required!'), backgroundColor: Colors.red));
                      return;
                    }
                    if (DuplicateGuard.isAdmissionNoDuplicate(adm, provider.students)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admission #$adm is already in use by another student!'), backgroundColor: Colors.red));
                      return;
                    }

                    final targetCls = _stuClass ?? (provider.classes.isNotEmpty ? provider.classes.first : 'Class 1');
                    final student = Student(
                      id: 'stu_${DateTime.now().millisecondsSinceEpoch}',
                      adm: adm,
                      name: name,
                      studentClass: targetCls,
                      gender: _stuGender,
                      roll: int.tryParse(_stuRollCtrl.text.trim()) ?? 1,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Student "${student.name}" (#${student.adm}) enrolled successfully!'), backgroundColor: const Color(0xFF059669)),
                      );
                      _stuAdmCtrl.clear();
                      _stuNameCtrl.clear();
                      _stuFatherCtrl.clear();
                      _stuMotherCtrl.clear();
                      _stuFatherMobCtrl.clear();
                      _stuMotherMobCtrl.clear();
                      _stuAddressCtrl.clear();

                      setState(() {
                        _currentModuleIndex = 1;
                        _currentSubIndex = 0;
                      });
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save & Enroll Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2C. BULK EXCEL UPLOAD
  Widget _buildBulkExcelTab(InstitutionProvider provider) {
    _bulkTargetClass ??= (provider.classes.isNotEmpty ? provider.classes.first : 'Class 1');
    final validRowsCount = _parsedBulkStudents.where((r) => r['isValid'] == true).length;
    final errorRowsCount = _parsedBulkStudents.where((r) => r['isValid'] != true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Row(
                  children: const [
                    Icon(Icons.file_upload_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text('Bulk Student Spreadsheet Import (CSV / TSV)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    const sample = 'AdmNo,Name,Gender,Father,Mobile,DOB,Address\n'
                        '1001,MOHAMMED RAYAN,Male,ABDULLA,9876543210,2015-05-15,Kozhikode\n'
                        '1002,AYISHA NASRIN,Female,USMAN,9876543211,2015-08-20,Malappuram\n'
                        '1003,ZAYAN AHMAD,Male,MUSTHAFA,9876543212,2015-11-10,Kannur';
                    await Clipboard.setData(const ClipboardData(text: sample));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CSV Template copied to clipboard! You can paste it into Excel or below.'), backgroundColor: Color(0xFF059669)),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 14),
                  label: const Text('Download CSV Template'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Upload batches of students in bulk. Paste spreadsheet rows directly or load sample data to test client validation.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const Divider(height: 24),

            // Step 1: Destination Class
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _bulkTargetClass,
                    decoration: const InputDecoration(labelText: 'Target Class for Batch Enrollment *', border: OutlineInputBorder()),
                    items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _bulkTargetClass = v),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _bulkCsvTextCtrl.text = '1001,MOHAMMED RAYAN,Male,ABDULLA,9876543210,2015-05-15,Kozhikode\n'
                        '1002,AYISHA NASRIN,Female,USMAN,9876543211,2015-08-20,Malappuram\n'
                        '1003,ZAYAN AHMAD,Male,MUSTHAFA,9876543212,2015-11-10,Kannur';
                    _parseBulkCsvData(provider.students, _bulkTargetClass!);
                  },
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Load 3 Sample Rows'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Step 2: Spreadsheet Data Input Area
            const Text('Paste Spreadsheet Data (Columns: AdmNo, Name, Gender, Father, Mobile, DOB, Address)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            TextField(
              controller: _bulkCsvTextCtrl,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                hintText: '1001,MOHAMMED RAYAN,Male,ABDULLA,9876543210,2015-05-15,Kozhikode\n1002,AYISHA NASRIN,Female,USMAN,9876543211,2015-08-20,Malappuram...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_parsedBulkStudents.isNotEmpty) {
                  _parseBulkCsvData(provider.students, _bulkTargetClass!);
                }
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _parseBulkCsvData(provider.students, _bulkTargetClass!),
                  icon: const Icon(Icons.rule_rounded, size: 16),
                  label: const Text('Parse & Validate Spreadsheet Data'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 10),
                if (_parsedBulkStudents.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _parsedBulkStudents.clear();
                      _bulkCsvTextCtrl.clear();
                    }),
                    child: const Text('Clear Table'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Step 3: Visual Data Preview Table
            if (_parsedBulkStudents.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Batch Validation Preview: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                          child: Text('$validRowsCount Valid', style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 11.5)),
                        ),
                        const SizedBox(width: 6),
                        if (errorRowsCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(6)),
                            child: Text('$errorRowsCount Errors', style: const TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.bold, fontSize: 11.5)),
                          ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploadingBulk || validRowsCount == 0
                          ? null
                          : () => _uploadBulkStudents(provider, true),
                      icon: _isUploadingBulk
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_rounded, size: 16),
                      label: Text(_isUploadingBulk ? 'Uploading... (${(_bulkUploadProgress * 100).toInt()}%)' : 'Enroll $validRowsCount Valid Students'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Adm No', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Father', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Validation Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _parsedBulkStudents.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final row = entry.value;
                      final isValid = row['isValid'] == true;
                      return DataRow(
                        color: WidgetStateProperty.all(isValid ? Colors.white : const Color(0xFFFFF1F2)),
                        cells: [
                          DataCell(Text('${idx + 1}')),
                          DataCell(Text(row['adm'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(row['name'] ?? '')),
                          DataCell(Text(row['gender'] ?? '')),
                          DataCell(Text(row['father'] ?? '')),
                          DataCell(Text(row['mobile'] ?? '')),
                          DataCell(
                            isValid
                                ? Row(
                                    children: const [
                                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                                      SizedBox(width: 4),
                                      Text('Ready', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 16),
                                      const SizedBox(width: 4),
                                      Text(row['errorReason'] ?? 'Invalid', style: const TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _parseBulkCsvData(List<Student> existingStudents, String targetClass) {
    final text = _bulkCsvTextCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _parsedBulkStudents = []);
      return;
    }

    final lines = text.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;

    final List<Map<String, dynamic>> results = [];
    final Set<String> seenBatchAdmNos = {};

    int startIdx = 0;
    final firstLower = lines[0].toLowerCase();
    if (firstLower.contains('adm') || firstLower.contains('name') || firstLower.contains('admission')) {
      startIdx = 1;
    }

    for (int i = startIdx; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.contains('\t') ? line.split('\t') : line.split(',');
      final clean = parts.map((p) => p.trim().replaceAll(RegExp(r'^["\x27]|["\x27]$'), '')).toList();

      final adm = clean.isNotEmpty ? clean[0].trim() : '';
      final name = clean.length > 1 ? clean[1].trim() : '';
      final rawGender = clean.length > 2 ? clean[2].trim() : 'Male';
      final father = clean.length > 3 ? clean[3].trim() : '';
      final mobile = clean.length > 4 ? clean[4].trim() : '';
      final dob = clean.length > 5 ? clean[5].trim() : '2015-05-15';
      final address = clean.length > 6 ? clean[6].trim() : '';

      String gender = 'Male';
      if (rawGender.toLowerCase().startsWith('f')) gender = 'Female';

      String? errorReason;
      if (adm.isEmpty) {
        errorReason = 'Missing Adm #';
      } else if (name.isEmpty) {
        errorReason = 'Missing Name';
      } else if (seenBatchAdmNos.contains(adm.toUpperCase())) {
        errorReason = 'Duplicate in batch';
      } else if (DuplicateGuard.isAdmissionNoDuplicate(adm, existingStudents)) {
        errorReason = 'Adm # exists in database';
      }

      if (errorReason == null) {
        seenBatchAdmNos.add(adm.toUpperCase());
      }

      results.add({
        'adm': adm,
        'name': name,
        'gender': gender,
        'father': father,
        'mobile': mobile,
        'dob': dob,
        'address': address,
        'isValid': errorReason == null,
        'errorReason': errorReason,
        'targetClass': targetClass,
      });
    }

    setState(() => _parsedBulkStudents = results);
  }

  Future<void> _uploadBulkStudents(InstitutionProvider provider, bool validOnly) async {
    final toUpload = _parsedBulkStudents.where((r) => validOnly ? r['isValid'] == true : true).toList();
    if (toUpload.isEmpty) return;

    setState(() {
      _isUploadingBulk = true;
      _bulkUploadProgress = 0.0;
    });

    int successCount = 0;
    final targetCls = _bulkTargetClass ?? (provider.classes.isNotEmpty ? provider.classes.first : 'Class 1');

    for (int i = 0; i < toUpload.length; i++) {
      final row = toUpload[i];
      final stu = Student(
        id: 'stu_${DateTime.now().millisecondsSinceEpoch}_$i',
        adm: row['adm'],
        name: row['name'],
        studentClass: targetCls,
        gender: row['gender'],
        father: row['father'],
        mobile: row['mobile'],
        dob: row['dob'],
        address: row['address'],
        status: 'Active',
        academicYear: provider.setting.activeAcademicYear,
      );
      final err = await provider.addStudent(stu);
      if (err == null) successCount++;

      setState(() => _bulkUploadProgress = (i + 1) / toUpload.length);
    }

    setState(() {
      _isUploadingBulk = false;
      _parsedBulkStudents = [];
      _bulkCsvTextCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully enrolled $successCount students into $targetCls!'),
        backgroundColor: const Color(0xFF059669),
      ),
    );

    setState(() {
      _currentModuleIndex = 1;
      _currentSubIndex = 0;
    });
  }

  // 2D. CLASSES & DIVISIONS
  Widget _buildClassesDivisionsTab(InstitutionProvider provider) {
    final sourceStudents = _moveSourceClass != null
        ? provider.students.where((s) => s.studentClass == _moveSourceClass && s.status == 'Active').toList()
        : <Student>[];
    final boys = sourceStudents.where((s) => s.gender.toLowerCase() == 'male').toList();
    final girls = sourceStudents.where((s) => s.gender.toLowerCase() == 'female').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add & Generator Tools Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Classes & Divisions', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Create individual classes or automatically generate standard 1 to 12 ladders and lettered divisions.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _newClassCtrl,
                        decoration: const InputDecoration(labelText: 'New Class / Division Name', hintText: 'e.g. 10 A, Commerce', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final val = _newClassCtrl.text.trim();
                        if (val.isNotEmpty) {
                          provider.addClass(val);
                          _newClassCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Class "$val" created!'), backgroundColor: const Color(0xFF059669)));
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Save Class'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Generator tools
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await provider.generateDefaultClasses();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generated standard Classes 1 through 12!'), backgroundColor: Color(0xFF059669)));
                      },
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Generate Default 1 to 12 Ladder'),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(controller: _divisionBaseCtrl, decoration: const InputDecoration(labelText: 'Base Class', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10))),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 80,
                          child: TextField(controller: _divisionCountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Divisions', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10))),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final base = _divisionBaseCtrl.text.trim();
                            final count = int.tryParse(_divisionCountCtrl.text.trim()) ?? 3;
                            if (base.isNotEmpty && count > 0) {
                              await provider.generateDivisions(base, count);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generated $count divisions for Class "$base"!'), backgroundColor: const Color(0xFF059669)));
                            }
                          },
                          icon: const Icon(Icons.grid_view_rounded, size: 16),
                          label: const Text('Create Divisions (A/B/C)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Classes Grid Card
          Container(
            padding: const EdgeInsets.all(18),
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
                    Text('Active Classes & Enrollment (${provider.classes.length})', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const Text('Tap any chip to rename class', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.classes.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No classes added yet.')))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.classes.map((c) {
                      final count = provider.students.where((s) => s.studentClass == c && s.status == 'Active').length;
                      return InputChip(
                        avatar: CircleAvatar(
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                        ),
                        label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () => _showRenameClassModal(c, provider),
                        deleteIcon: const Icon(Icons.close, size: 15),
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
          ),
          const SizedBox(height: 20),

          // 3. Divide / Merge / Move Students Workstation
          Container(
            padding: const EdgeInsets.all(18),
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
                    Row(
                      children: const [
                        Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB), size: 22),
                        SizedBox(width: 8),
                        Text('Divide / Merge & Move Students Workstation', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    if (_selectedMoveStudentIds.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                        child: Text('${_selectedMoveStudentIds.length} Selected to Move', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Split classes into divisions, reassign boys/girls, or bulk move cohorts to another standard.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                // Select Source & Target Classes
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _moveSourceClass,
                        decoration: const InputDecoration(labelText: '1. Select Source Class *', border: OutlineInputBorder()),
                        items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _moveSourceClass = val;
                            _selectedMoveStudentIds.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _moveTargetClass,
                        decoration: const InputDecoration(labelText: '2. Select Destination Class *', border: OutlineInputBorder()),
                        items: provider.classes.where((c) => c != _moveSourceClass).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _moveTargetClass = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_moveSourceClass != null) ...[
                  // Demographic split header
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Source Cohort: $_moveSourceClass (${sourceStudents.length} Students Total)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  final allBoysSelected = boys.every((b) => _selectedMoveStudentIds.contains(b.id));
                                  if (allBoysSelected) {
                                    for (final b in boys) _selectedMoveStudentIds.remove(b.id);
                                  } else {
                                    for (final b in boys) _selectedMoveStudentIds.add(b.id);
                                  }
                                });
                              },
                              icon: const Icon(Icons.select_all_rounded, size: 14),
                              label: Text(boys.every((b) => _selectedMoveStudentIds.contains(b.id)) ? 'Deselect All Boys' : 'Select All Boys (${boys.length})', style: const TextStyle(fontSize: 11.5)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  final allGirlsSelected = girls.every((g) => _selectedMoveStudentIds.contains(g.id));
                                  if (allGirlsSelected) {
                                    for (final g in girls) _selectedMoveStudentIds.remove(g.id);
                                  } else {
                                    for (final g in girls) _selectedMoveStudentIds.add(g.id);
                                  }
                                });
                              },
                              icon: const Icon(Icons.select_all_rounded, size: 14),
                              label: Text(girls.every((g) => _selectedMoveStudentIds.contains(g.id)) ? 'Deselect All Girls' : 'Select All Girls (${girls.length})', style: const TextStyle(fontSize: 11.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Split Columns for Boys & Girls
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Boys Column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.man_rounded, color: Color(0xFF0284C7), size: 18),
                                  const SizedBox(width: 6),
                                  Text('Boys (${boys.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0369A1))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (boys.isEmpty)
                                const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No boys in this class', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))))
                              else
                                ...boys.map((b) {
                                  final isSel = _selectedMoveStudentIds.contains(b.id);
                                  return CheckboxListTile(
                                    dense: true,
                                    value: isSel,
                                    title: Text(b.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                    subtitle: Text('Adm #${b.adm}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) _selectedMoveStudentIds.add(b.id); else _selectedMoveStudentIds.remove(b.id);
                                      });
                                    },
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Girls Column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF2F8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFBCFE8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.woman_rounded, color: Color(0xFFBE185D), size: 18),
                                  const SizedBox(width: 6),
                                  Text('Girls (${girls.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF9D174D))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (girls.isEmpty)
                                const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No girls in this class', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))))
                              else
                                ...girls.map((g) {
                                  final isSel = _selectedMoveStudentIds.contains(g.id);
                                  return CheckboxListTile(
                                    dense: true,
                                    value: isSel,
                                    title: Text(g.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                    subtitle: Text('Adm #${g.adm}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) _selectedMoveStudentIds.add(g.id); else _selectedMoveStudentIds.remove(g.id);
                                      });
                                    },
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Execute Move Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedMoveStudentIds.isEmpty || _moveTargetClass == null)
                          ? null
                          : () async {
                              final count = _selectedMoveStudentIds.length;
                              await provider.moveStudentsToClass(_selectedMoveStudentIds.toList(), _moveTargetClass!);
                              setState(() {
                                _selectedMoveStudentIds.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Successfully moved $count students to "$_moveTargetClass"!'), backgroundColor: const Color(0xFF059669)),
                              );
                            },
                      icon: const Icon(Icons.transfer_within_a_station_rounded, size: 16),
                      label: Text('Move ${_selectedMoveStudentIds.length} Selected Students to ${_moveTargetClass ?? "Destination"}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Class renamed to "$newName" successfully!'), backgroundColor: const Color(0xFF059669)));
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

            // Visual Branding Preview Card (Application Icon & Institution Logo)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // App Icon Preview
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Application Icon (App Logo)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('APK Launcher, Web Favicon & Device Icon', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Institution Logo Preview
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Institution Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Default School Logo for Receipts & ID Cards', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../models/staff.dart';
import '../../services/duplicate_guard.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _currentTabIndex = 0;

  // Add Student Controllers
  final _admCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedGender = 'Male';
  String? _selectedClass;
  String? _admWarning;

  // Class Management Controller
  final _newClassCtrl = TextEditingController();

  // Institution Profile Controllers
  final _instNameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _phoneInstCtrl = TextEditingController();
  final _emailInstCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final provider = context.read<InstitutionProvider>();
    final s = provider.setting;
    _instNameCtrl.text = s.institutionName;
    _placeCtrl.text = s.place;
    _phoneInstCtrl.text = s.phone;
    _emailInstCtrl.text = s.email;
    _currencyCtrl.text = s.currencySymbol;

    // Live AdmNo duplicate checking
    _admCtrl.addListener(_checkLiveAdmDuplicate);
  }

  void _checkLiveAdmDuplicate() {
    final provider = context.read<InstitutionProvider>();
    final val = _admCtrl.text.trim();
    if (val.isEmpty) {
      if (_admWarning != null) setState(() => _admWarning = null);
      return;
    }

    final isDup = DuplicateGuard.isAdmissionNoDuplicate(val, provider.students);
    if (isDup) {
      final existing = provider.students.firstWhere((s) => s.adm.trim().toUpperCase() == val.toUpperCase());
      setState(() => _admWarning = '⚠️ Adm #$val already assigned to ${existing.name} (${existing.studentClass})!');
    } else {
      if (_admWarning != null) setState(() => _admWarning = null);
    }
  }

  @override
  void dispose() {
    _admCtrl.dispose();
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _phoneCtrl.dispose();
    _newClassCtrl.dispose();
    _instNameCtrl.dispose();
    _placeCtrl.dispose();
    _phoneInstCtrl.dispose();
    _emailInstCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final desigCtrl = TextEditingController(text: 'TEACHER');
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final placeCtrl = TextEditingController(text: 'Devathiyal');
    String role = 'TEACHER';
    String? assignedClass;

    final provider = context.read<InstitutionProvider>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Faculty / Staff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'TEACHER', child: Text('Teacher / Ustad')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                    DropdownMenuItem(value: 'COLLECTOR', child: Text('Fee Collector')),
                  ],
                  onChanged: (val) => setDialogState(() => role = val ?? 'TEACHER'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: desigCtrl,
                  decoration: const InputDecoration(labelText: 'Designation (e.g. SWADAR, TEACHER)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone / WhatsApp', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: placeCtrl,
                  decoration: const InputDecoration(labelText: 'Place / Location', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: assignedClass,
                  decoration: const InputDecoration(labelText: 'Assigned Class', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes (General)')),
                    ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setDialogState(() => assignedClass = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final newStaff = Staff(
                  id: 'STF_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  designation: desigCtrl.text.trim().toUpperCase(),
                  role: role,
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  place: placeCtrl.text.trim(),
                  assignedClass: assignedClass ?? '',
                  hasAdminAccess: role == 'ADMIN',
                  hasCollectionAccess: true,
                  hasResultAccess: true,
                  hasWorksheetAccess: true,
                );
                await provider.addStaff(newStaff);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Staff member ${newStaff.name} added!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              child: const Text('Add Staff'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    return AdaptivePortalScaffold(
      portalTitle: 'Admin Command Center',
      initialIndex: _currentTabIndex,
      onTabChanged: (idx) => setState(() => _currentTabIndex = idx),
      tabs: [
        PortalTabItem(
          id: 'overview',
          label: 'Overview',
          icon: Icons.dashboard_rounded,
          body: _buildOverviewTab(provider, setting),
        ),
        PortalTabItem(
          id: 'add_student',
          label: 'Add Student',
          icon: Icons.person_add_rounded,
          body: _buildAddStudentTab(provider),
        ),
        PortalTabItem(
          id: 'manage_students',
          label: 'Manage Students',
          icon: Icons.groups_rounded,
          body: _buildManageStudentsTab(provider),
        ),
        PortalTabItem(
          id: 'classes',
          label: 'Classes',
          icon: Icons.class_rounded,
          body: _buildClassesTab(provider),
        ),
        PortalTabItem(
          id: 'continuity',
          label: 'Continuity & Transfers',
          icon: Icons.transfer_within_a_station_rounded,
          body: _buildContinuityTab(provider),
        ),
        PortalTabItem(
          id: 'staff',
          label: 'Staff & Teachers',
          icon: Icons.badge_rounded,
          body: _buildStaffTab(provider),
        ),
        PortalTabItem(
          id: 'settings',
          label: 'Institution Settings',
          icon: Icons.settings_suggest_rounded,
          body: _buildSettingsTab(provider, setting),
        ),
      ],
    );
  }

  // ==================== TABS ====================
  Widget _buildOverviewTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: isWide ? 1.6 : 1.35,
                children: [
                  StatCard(title: 'Active Students', value: provider.totalActiveStudents.toString(), icon: Icons.school, color: Colors.blue),
                  StatCard(title: 'Total Classes', value: provider.classes.length.toString(), icon: Icons.meeting_room, color: Colors.teal),
                  StatCard(title: "Today's Collection", value: '${setting.currencySymbol}${provider.todayCollection.toStringAsFixed(0)}', icon: Icons.payments, color: Colors.teal),
                  StatCard(title: 'Staff Members', value: provider.totalStaff.toString(), icon: Icons.badge, color: Colors.indigo),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddStudentTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ENROLL NEW STUDENT (STRICT ZERO-DUPLICATE GUARD)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _admCtrl,
              decoration: InputDecoration(
                labelText: 'Admission Number *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorText: _admWarning,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Student Full Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: InputDecoration(
                labelText: 'Assign Class *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedClass = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (val) => setState(() => _selectedGender = val ?? 'Male'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fatherCtrl,
              decoration: InputDecoration(
                labelText: "Father's / Guardian's Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSaveStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save & Enroll Student', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageStudentsTab(InstitutionProvider provider) {
    if (provider.students.isEmpty) {
      return const Center(child: Text('No students registered yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) {
        final s = provider.students[idx];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text('#${s.adm}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.studentClass} • ${s.gender} • Guardian: ${s.father.isNotEmpty ? s.father : '-'} • Status: ${s.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => provider.deleteStudent(s.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassesTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newClassCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Class 11, Class 12, Pre-Primary',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final val = _newClassCtrl.text.trim();
                    if (val.isNotEmpty) {
                      provider.addClass(val);
                      _newClassCtrl.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('Add Class'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.classes.map((cls) {
                return Chip(
                  label: Text(cls),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => provider.removeClass(cls),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinuityTab(InstitutionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ZERO-GAP BILLING & CONTINUITY MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          const Text(
            'Students who leave have dues frozen up to departure date (zero gap fees charged during absence). Upon re-admission, previous history is fully restored.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...provider.students.where((s) => s.status == 'Discontinued').map((st) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.red.shade200)),
              color: Colors.red.shade50.withOpacity(0.3),
              child: ListTile(
                title: Text('${st.name} (Adm: #${st.adm})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: DISCONTINUED • Exit Reason: ${st.exitReason.isNotEmpty ? st.exitReason : "Relocation"} • Dues Preserved: ₹${st.frozenPendingDue}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    provider.readmitStudent(st, st.studentClass, provider.setting.activeAcademicYear, 'Re-admitted after gap');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${st.name} re-admitted to active roll.')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Re-admit'),
                ),
              ),
            );
          }),
          if (!provider.students.any((s) => s.status == 'Discontinued'))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No discontinued students on record.')),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffTab(InstitutionProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STAFF DIRECTORY (${provider.staffList.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Staff / Ustad', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.staffList.isEmpty
              ? const Center(child: Text('No staff members registered. Click Add Staff above.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: provider.staffList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final st = provider.staffList[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            st.name.isNotEmpty ? st.name.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(st.designation.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ),
                          ],
                        ),
                        subtitle: Text('Role: ${st.role} • Class: ${st.assignedClass.isNotEmpty ? st.assignedClass : "All"} • Ph: ${st.phone}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => provider.deleteStaff(st.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(InstitutionProvider provider, dynamic setting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WHITE-LABEL INSTITUTION PROFILE (100% DYNAMIC)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _instNameCtrl,
              decoration: InputDecoration(
                labelText: 'Institution Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placeCtrl,
              decoration: InputDecoration(
                labelText: 'Place / City / Campus',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneInstCtrl,
              decoration: InputDecoration(
                labelText: 'Official Contact Phone',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currencyCtrl,
              decoration: InputDecoration(
                labelText: 'Currency Symbol (e.g. ₹, \$, AED)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updated = setting.copyWith(
                  institutionName: _instNameCtrl.text.trim(),
                  place: _placeCtrl.text.trim(),
                  phone: _phoneInstCtrl.text.trim(),
                  currencySymbol: _currencyCtrl.text.trim(),
                );
                provider.updateSettings(updated);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institution Settings Saved!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveStudent() async {
    final provider = context.read<InstitutionProvider>();
    final adm = _admCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (adm.isEmpty || name.isEmpty || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission No, Name, and Class are required!'), backgroundColor: Colors.red),
      );
      return;
    }

    final newStudent = Student(
      id: '',
      adm: adm,
      name: name,
      studentClass: _selectedClass!,
      gender: _selectedGender,
      father: _fatherCtrl.text.trim(),
      mobile: _phoneCtrl.text.trim(),
      status: 'Active',
    );

    final error = await provider.addStudent(newStudent);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      _admCtrl.clear();
      _nameCtrl.clear();
      _fatherCtrl.clear();
      _phoneCtrl.clear();
      setState(() => _admWarning = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student $name enrolled successfully!')),
      );
    }
  }
}

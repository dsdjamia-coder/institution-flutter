import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../models/institution_setting.dart';
import '../../services/duplicate_guard.dart';
import '../../widgets/stat_card.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    _tabController = TabController(length: 6, vsync: this);

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
    _tabController.dispose();
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
          'Admin Command Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue.shade700,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Overview'),
            Tab(icon: Icon(Icons.person_add, size: 18), text: 'Add Student'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Manage Students'),
            Tab(icon: Icon(Icons.class_, size: 18), text: 'Classes'),
            Tab(icon: Icon(Icons.transfer_within_a_station, size: 18), text: 'Continuity & Transfers'),
            Tab(icon: Icon(Icons.business, size: 18), text: 'Institution Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: OVERVIEW
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(title: 'Active Students', value: provider.totalActiveStudents.toString(), icon: Icons.school, color: Colors.blue),
                    StatCard(title: 'Total Classes', value: provider.classes.length.toString(), icon: Icons.meeting_room, color: Colors.teal),
                    StatCard(title: "Today's Collection", value: '${setting.currencySymbol}${provider.todayCollection.toStringAsFixed(0)}', icon: Icons.payments, color: Colors.emerald),
                    StatCard(title: 'Staff Members', value: provider.totalStaff.toString(), icon: Icons.badge, color: Colors.indigo),
                  ],
                ),
              ],
            ),
          ),

          // TAB 2: ADD STUDENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ENROLL NEW STUDENT (MANUAL ENTRY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 16),

                  // Admission No with Live Warning
                  TextField(
                    controller: _admCtrl,
                    decoration: InputDecoration(
                      labelText: 'Admission Number (Unique) *',
                      prefixIcon: const Icon(Icons.tag),
                      errorText: _admWarning,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Full Name
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Student Full Name *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Class Selector
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: InputDecoration(
                      labelText: 'Assign Class *',
                      prefixIcon: const Icon(Icons.class_),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedClass = val),
                  ),
                  const SizedBox(height: 14),

                  // Gender
                  Row(
                    children: [
                      const Text('Gender: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Radio<String>(value: 'Male', groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v!)),
                      const Text('Male'),
                      Radio<String>(value: 'Female', groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v!)),
                      const Text('Female'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Guardian & Phone
                  TextField(
                    controller: _fatherCtrl,
                    decoration: InputDecoration(
                      labelText: "Father's / Guardian's Name",
                      prefixIcon: const Icon(Icons.family_restroom),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Parent Mobile Phone (Login Credential)',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _handleSaveStudent,
                    icon: const Icon(Icons.save),
                    label: const Text('Save & Enroll Student'),
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
          ),

          // TAB 3: MANAGE STUDENTS
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: provider.students.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No students registered yet.')))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final s = provider.students[idx];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text(s.adm, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Class: ${s.studentClass} • Father: ${s.father.isNotEmpty ? s.father : '-'} • Status: ${s.status}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => provider.deleteStudent(s.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // TAB 4: CLASSES
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newClassCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter new class (e.g. Class 1, Grade 5)...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_newClassCtrl.text.isNotEmpty) {
                          provider.addClass(_newClassCtrl.text.trim());
                          _newClassCtrl.clear();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Class'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.classes.isEmpty
                      ? const Center(child: Text('No classes added yet. Add classes above.'))
                      : ListView.separated(
                          itemCount: provider.classes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, idx) {
                            final c = provider.classes[idx];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                              child: ListTile(
                                leading: const Icon(Icons.meeting_room, color: Colors.blue),
                                title: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => provider.removeClass(c),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB 5: STUDENT CONTINUITY (Discontinue & Re-admission)
          SingleChildScrollView(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.rose.shade200)),
                    color: Colors.rose.shade50.withOpacity(0.3),
                    child: ListTile(
                      title: Text('${st.name} (Adm: #${st.adm})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Status: DISCONTINUED • Frozen Dues: ${setting.currencySymbol}${st.frozenPendingDue}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          provider.updateStudent(st.copyWith(status: 'Active'));
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
          ),

          // TAB 6: INSTITUTION SETTINGS (100% White-Label)
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
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
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Profile Settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
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

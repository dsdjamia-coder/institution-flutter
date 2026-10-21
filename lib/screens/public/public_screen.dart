import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/compound_student_search.dart';
import '../../models/student.dart';
import '../official/official_hub_screen.dart';
import '../student/student_portal_screen.dart';
import '../admin/admin_console_screen.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Icon(Icons.school, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.institutionName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (setting.place.isNotEmpty)
                    Text(
                      setting.place,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openLoginModal(context),
              icon: const Icon(Icons.lock_open, size: 16),
              label: const Text('Portal Login', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.indigo.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade700.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      setting.type.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    setting.institutionName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    setting.aboutText.isNotEmpty
                        ? setting.aboutText
                        : 'Comprehensive Academic, Fee, and Administrative Management Platform.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openLoginModal(context),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Student & Staff Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminConsoleScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings, size: 16, color: Colors.white),
                        label: const Text('Admin Console', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Stats Grid
            const Text(
              'LIVE INSTITUTION METRICS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth > 700 ? 1.8 : 1.3,
                  children: [
                    StatCard(
                      title: 'Total Students',
                      value: provider.totalActiveStudents.toString(),
                      icon: Icons.people_alt,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Faculty & Staff',
                      value: provider.totalStaff.toString(),
                      icon: Icons.badge,
                      color: Colors.indigo,
                    ),
                    StatCard(
                      title: 'Male Students',
                      value: provider.totalBoys.toString(),
                      icon: Icons.male,
                      color: Colors.teal,
                    ),
                    StatCard(
                      title: 'Female Students',
                      value: provider.totalGirls.toString(),
                      icon: Icons.female,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Quick Access Portals
            const Text(
              'MANAGEMENT PORTALS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            _buildPortalCard(
              context,
              title: 'Official Staff Hub',
              subtitle: 'Unified workspace for class teachers, fee cashiers, and operators.',
              icon: Icons.dashboard_customize,
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfficialHubScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildPortalCard(
              context,
              title: 'Student & Parent Portal',
              subtitle: 'Access digital ID cards, fee transaction receipts, and report cards.',
              icon: Icons.school,
              color: Colors.teal.shade700,
              onTap: () => _openLoginModal(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ==================== UNIVERSAL LOGIN MODAL ====================
  void _openLoginModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _UniversalLoginDialog(),
    );
  }
}

class _UniversalLoginDialog extends StatefulWidget {
  const _UniversalLoginDialog();

  @override
  State<_UniversalLoginDialog> createState() => _UniversalLoginDialogState();
}

class _UniversalLoginDialogState extends State<_UniversalLoginDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student Login fields
  String? _selectedClass;
  Student? _selectedStudent;
  final TextEditingController _studentPhoneCtrl = TextEditingController();

  // Staff Login fields
  final TextEditingController _staffIdCtrl = TextEditingController();
  final TextEditingController _staffPassCtrl = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentPhoneCtrl.dispose();
    _staffIdCtrl.dispose();
    _staffPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Universal Portal Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue.shade600,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.person, size: 18), text: 'Student / Parent'),
                  Tab(icon: Icon(Icons.badge, size: 18), text: 'Official Staff'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Student Login
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class filter
                      DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: InputDecoration(
                          labelText: 'Filter by Class',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Classes')),
                          ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                          const DropdownMenuItem(value: 'Alumni', child: Text('🎓 Alumni')),
                        ],
                        onChanged: (val) => setState(() => _selectedClass = val),
                      ),
                      const SizedBox(height: 10),
                      // Compound student search
                      CompoundStudentSearch(
                        students: provider.students,
                        selectedClass: _selectedClass,
                        selectedStudent: _selectedStudent,
                        hintText: 'Type Name or Adm No...',
                        onStudentSelected: (s) => setState(() => _selectedStudent = s),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _studentPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Registered Mobile Phone',
                          prefixIcon: const Icon(Icons.phone, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _handleStudentLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Login to Student Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  // Tab 2: Staff Login
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _staffIdCtrl,
                        decoration: InputDecoration(
                          labelText: 'Staff ID or Email',
                          prefixIcon: const Icon(Icons.account_circle, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _staffPassCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _handleStaffLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Login as Official Staff', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _handleStudentLogin() {
    final provider = context.read<InstitutionProvider>();
    final phone = _studentPhoneCtrl.text.trim();

    if (_selectedStudent == null) {
      setState(() => _errorMessage = 'Please search and select your student record.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your registered mobile number.');
      return;
    }

    final student = provider.authenticateStudent(
      _selectedClass ?? '',
      _selectedStudent!.adm,
      phone,
    );

    if (student != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudentPortalScreen()),
      );
    } else {
      setState(() => _errorMessage = 'Mobile phone number does not match registered student record.');
    }
  }

  void _handleStaffLogin() {
    final provider = context.read<InstitutionProvider>();
    final id = _staffIdCtrl.text.trim();
    final pass = _staffPassCtrl.text.trim();

    if (id.isEmpty) {
      setState(() => _errorMessage = 'Please enter your staff ID or email.');
      return;
    }

    final staff = provider.authenticateStaff(id, pass);
    if (staff != null) {
      Navigator.pop(context);
      if (staff.hasAdminAccess) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminConsoleScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfficialHubScreen()),
        );
      }
    } else {
      setState(() => _errorMessage = 'Invalid staff credentials.');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../core/routing/app_router.dart';
import '../../screens/student/student_portal_screen.dart';
import '../../screens/official/official_hub_screen.dart';

class SecureLoginModal extends StatefulWidget {
  const SecureLoginModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const SecureLoginModal(),
    );
  }

  @override
  State<SecureLoginModal> createState() => _SecureLoginModalState();
}

class _SecureLoginModalState extends State<SecureLoginModal> {
  // Selected class determines mode:
  // - If null / empty: Staff / Admin mode (Username or Email + Password)
  // - If selected: Student / Alumni mode (Search Name/Adm + Mobile Number)
  String? _selectedClass;
  Student? _selectedStudent;
  bool _obscurePassword = true;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  bool get _isStudentMode => _selectedClass != null && _selectedClass!.isNotEmpty;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final provider = context.read<InstitutionProvider>();

    try {
      if (_isStudentMode) {
        // ==================== STUDENT LOGIN ====================
        final query = _identifierController.text.trim();
        final password = _passwordController.text.trim();

        if (query.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter student Name or Admission No.';
            _isLoading = false;
          });
          return;
        }

        if (password.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter registered mobile number as password.';
            _isLoading = false;
          });
          return;
        }

        // Search student matching class and query (Adm or Name)
        final cleanPhone = password.replaceAll(RegExp(r'\D'), '').trim();
        final isAlumni = _selectedClass == 'Alumni';

        Student? student = _selectedStudent;
        if (student == null) {
          final matched = provider.students.where((s) {
            final classMatch = isAlumni
                ? (s.status.toLowerCase() == 'alumni' || s.studentClass.toLowerCase() == 'alumni')
                : (s.studentClass.toLowerCase() == _selectedClass!.toLowerCase());
            final queryMatch = s.adm.toLowerCase() == query.toLowerCase() ||
                s.name.toLowerCase().contains(query.toLowerCase());
            return classMatch && queryMatch;
          }).toList();

          if (matched.isNotEmpty) {
            student = matched.first;
          }
        }

        if (student == null) {
          setState(() {
            _errorMessage = 'No student found in $_selectedClass matching "$query".';
            _isLoading = false;
          });
          return;
        }

        // Verify password against student's registered mobile number
        final studentPhone = student.mobile.replaceAll(RegExp(r'\D'), '').trim();
        if (studentPhone.isNotEmpty && cleanPhone != studentPhone) {
          setState(() {
            _errorMessage = 'Incorrect mobile number password. Please verify.';
            _isLoading = false;
          });
          return;
        }

        provider.loginStudent(student);
        if (mounted) {
          Navigator.pop(context);
          context.push(AppRouter.student);
        }
      } else {
        // ==================== STAFF / ADMIN LOGIN ====================
        final identifier = _identifierController.text.trim();
        final password = _passwordController.text.trim();

        if (identifier.isEmpty || password.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter Admin / Staff email and password.';
            _isLoading = false;
          });
          return;
        }

        final success = await provider.loginStaff(identifier, password);
        if (success && mounted) {
          Navigator.pop(context);
          context.push(AppRouter.hub);
        } else {
          setState(() {
            _errorMessage = 'Invalid credentials. Please verify your login.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final classes = ['Select Class', ...provider.classes, 'Alumni'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Row: Close button on right
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),

              // Blue Lock Badge at Top Center
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Icon(
                  _isStudentMode ? Icons.school_rounded : Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF2563EB),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),

              // Title: Secure Login
              Text(
                _isStudentMode
                    ? (_selectedClass == 'Alumni' ? 'Alumni Portal Login' : 'Student Login (${_selectedClass!})')
                    : 'Staff & Admin Login',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Subtitle hint explaining single login mechanism
              Text(
                _isStudentMode
                    ? 'Enter name or admission number with registered mobile number'
                    : 'Select class for student login, or enter credentials for admin/staff',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // 1. Unified Select Class Dropdown
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isStudentMode ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: _isStudentMode ? 1.5 : 1.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedClass,
                    hint: const Row(
                      children: [
                        Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 8),
                        Text(
                          'Select Class (Leave blank for Admin)',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    items: classes.map((c) {
                      return DropdownMenuItem<String>(
                        value: c == 'Select Class' ? null : c,
                        child: Row(
                          children: [
                            Icon(
                              c == 'Select Class'
                                  ? Icons.clear_rounded
                                  : (c == 'Alumni' ? Icons.history_edu_rounded : Icons.class_rounded),
                              size: 16,
                              color: c == 'Alumni' ? const Color(0xFFF59E0B) : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: c == 'Select Class' ? FontWeight.normal : FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedClass = val;
                        _selectedStudent = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Dynamic Identifier Input Field
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _identifierController,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      _isStudentMode ? Icons.badge_outlined : Icons.email_outlined,
                      size: 18,
                      color: const Color(0xFF64748B),
                    ),
                    hintText: _isStudentMode ? 'Search Name or Adm No' : 'Email (e.g. nimdevathiyal4883@gmail.com)',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Dynamic Password Input Field
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: _isStudentMode ? TextInputType.phone : TextInputType.text,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      _isStudentMode ? Icons.phone_android_rounded : Icons.lock_outline_rounded,
                      size: 18,
                      color: const Color(0xFF64748B),
                    ),
                    hintText: _isStudentMode ? 'Password (Registered Mobile)' : 'Password',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Large Navy Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleLogin,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    _isLoading
                        ? 'Authenticating...'
                        : (_isStudentMode ? 'Login as Student' : 'Login as Staff / Admin'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

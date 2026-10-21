import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
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
  bool _isStaffMode = false;
  bool _obscurePassword = true;

  // Student mode state
  String? _selectedClass;
  Student? _selectedStudent;
  final TextEditingController _studentSearchController = TextEditingController();
  final TextEditingController _studentPasswordController = TextEditingController();

  // Staff mode state
  final TextEditingController _staffEmailController = TextEditingController();
  final TextEditingController _staffPasswordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _studentSearchController.dispose();
    _studentPasswordController.dispose();
    _staffEmailController.dispose();
    _staffPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final provider = context.read<InstitutionProvider>();

    try {
      if (!_isStaffMode) {
        // Student Login
        final query = _studentSearchController.text.trim();
        final password = _studentPasswordController.text.trim();

        if (_selectedStudent == null && query.isEmpty) {
          setState(() {
            _errorMessage = 'Please select or search your name / Adm No.';
            _isLoading = false;
          });
          return;
        }

        // Try to find student if not selected from suggestions
        Student? student = _selectedStudent;
        if (student == null) {
          final matched = provider.students.where((s) {
            final matchesClass = _selectedClass == null || _selectedClass!.isEmpty || s.studentClass == _selectedClass;
            final matchesQuery = s.adm.toLowerCase() == query.toLowerCase() ||
                s.name.toLowerCase().contains(query.toLowerCase());
            return matchesClass && matchesQuery;
          }).toList();

          if (matched.isNotEmpty) {
            student = matched.first;
          }
        }

        if (student == null) {
          // If Firestore is empty, allow a demo student login so user can preview the student portal
          if (provider.students.isEmpty) {
            student = Student(
              id: 'demo-student-1',
              adm: query.isNotEmpty ? query : '4883',
              name: query.isNotEmpty ? query : 'Student Preview',
              studentClass: _selectedClass ?? 'Class 10',
              mobile: password.isNotEmpty ? password : '9946806268',
              gender: 'Male',
              father: 'Father Name',
            );
          } else {
            setState(() {
              _errorMessage = 'Student not found. Please verify details.';
              _isLoading = false;
            });
            return;
          }
        }

        provider.loginStudent(student);
        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentPortalScreen()),
          );
        }
      } else {
        // Staff Login
        final email = _staffEmailController.text.trim();
        final password = _staffPasswordController.text.trim();

        if (email.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter your Admin/Staff email or phone.';
            _isLoading = false;
          });
          return;
        }

        final success = await provider.loginStaff(email, password);
        if (success && mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OfficialHubScreen()),
          );
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
    final classes = ['All Classes', ...provider.classes, 'Alumni'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 360,
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),

              // Title: Secure Login
              const Text(
                'Secure Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),

              // Mode toggle: Student Login / Staff Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Student Login', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: !_isStaffMode,
                    selectedColor: const Color(0xFFEFF6FF),
                    labelStyle: TextStyle(color: !_isStaffMode ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                    onSelected: (val) {
                      setState(() {
                        _isStaffMode = false;
                        _errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Admin / Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: _isStaffMode,
                    selectedColor: const Color(0xFFEFF6FF),
                    labelStyle: TextStyle(color: _isStaffMode ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                    onSelected: (val) {
                      setState(() {
                        _isStaffMode = true;
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Form fields based on mode
              if (!_isStaffMode) ...[
                // Select Class Dropdown
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedClass,
                      hint: const Text('Select Class', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      items: classes.map((c) {
                        return DropdownMenuItem(
                          value: c == 'All Classes' ? null : c,
                          child: Text(c, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedClass = val;
                          _selectedStudent = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Search Name or Adm No input
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _studentSearchController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      hintText: 'Search Name or Adm No',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password (Mobile Number) input with eye icon
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _studentPasswordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Password (Mobile Number)',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
              ] else ...[
                // Staff Email / Phone
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _staffEmailController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      hintText: 'Email (Admin / Staff)',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Staff Password with eye icon
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _staffPasswordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
              ],

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),

              // Large Dark Navy Button: ➔ Login Securely
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
                    _isLoading ? 'Authenticating...' : 'Login Securely',
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

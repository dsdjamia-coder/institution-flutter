import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/staff.dart';
import '../../widgets/landing/landing_stat_card.dart';
import '../../widgets/landing/teacher_card.dart';
import '../../widgets/landing/secure_login_modal.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _teachersKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    // Faculty members (use provider staff or screenshot defaults)
    final teachers = provider.staffList.isNotEmpty
        ? provider.staffList
        : [
            Staff(
              id: 'ustad-1',
              name: 'Muhammad Anas Faizy T',
              role: 'TEACHER',
              designation: 'SWADAR',
              phone: '+91 9946 806 268',
              place: 'Devathiyal',
            ),
            Staff(
              id: 'ustad-2',
              name: 'Moideen Kottkuth',
              role: 'TEACHER',
              designation: 'TEACHER',
              phone: '+91 9946 806 268',
              place: 'Devathiyal',
            ),
            Staff(
              id: 'ustad-3',
              name: 'Shahul Hameed Rahmani',
              role: 'TEACHER',
              designation: 'TEACHER',
              phone: '+91 9946 806 268',
              place: 'Devathiyal',
            ),
          ];

    // Compute metrics
    final totalStudents = provider.totalStudents > 0
        ? provider.totalStudents.toString()
        : setting.defaultStudentsCount.toString();

    final totalTeachers = provider.totalStaff > 0
        ? provider.totalStaff.toString()
        : setting.defaultTeachersCount.toString();

    final maleCount = provider.totalStudents > 0
        ? provider.students.where((s) => s.gender.toLowerCase() == 'male').length.toString()
        : setting.defaultMaleCount.toString();

    final femaleCount = provider.totalStudents > 0
        ? provider.students.where((s) => s.gender.toLowerCase() == 'female').length.toString()
        : setting.defaultFemaleCount.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      // Top App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Row(
          children: [
            // Logo Box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(width: 10),
            // Title & Reg/Place
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    setting.institutionName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Reg: ${setting.regNo} | ${setting.place}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Hamburger Drawer Menu Trigger
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 26),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      // End Drawer Navigation
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            setting.institutionName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text('Reg: ${setting.regNo}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: Color(0xFF2563EB)),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                title: const Text('About Us'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToKey(_aboutKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.co_present_outlined, color: Color(0xFF2563EB)),
                title: const Text('Teachers'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToKey(_teachersKey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Color(0xFF2563EB)),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToKey(_galleryKey);
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      SecureLoginModal.show(context);
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Login Portal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Scrollable Body
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 28),

            // 1. HERO SECTION
            Center(
              child: Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 48, color: Color(0xFF2563EB)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Large Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                setting.institutionName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle: Run by ...
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Run by: ${setting.managementName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Reg info
            Text(
              'Reg No: ${setting.regNo} | ${setting.place}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Main Action Button: ➔ Login
            ElevatedButton.icon(
              onPressed: () => SecureLoginModal.show(context),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Login',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Quick Navigation Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _scrollToKey(_teachersKey),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.co_present, size: 16, color: Color(0xFFF59E0B)),
                        SizedBox(width: 6),
                        Text(
                          'Teachers',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _scrollToKey(_galleryKey),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 16, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          'Gallery',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 2. STATS GRID (2x2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LandingStatCard(
                          title: 'STUDENTS',
                          count: totalStudents,
                          icon: Icons.groups_rounded,
                          accentColor: const Color(0xFF2563EB), // Blue
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LandingStatCard(
                          title: 'TEACHERS',
                          count: totalTeachers,
                          icon: Icons.co_present_rounded,
                          accentColor: const Color(0xFFF59E0B), // Orange/Yellow
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LandingStatCard(
                          title: 'MALE',
                          count: maleCount,
                          icon: Icons.person_rounded,
                          accentColor: const Color(0xFF10B981), // Green
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LandingStatCard(
                          title: 'FEMALE',
                          count: femaleCount,
                          icon: Icons.woman_rounded,
                          accentColor: const Color(0xFF06B6D4), // Cyan/Teal
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 3. ABOUT US SECTION
            Container(
              key: _aboutKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 38,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      setting.aboutText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.65,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 4. TEACHERS SECTION
            Container(
              key: _teachersKey,
              child: Column(
                children: [
                  const Text(
                    'TEACHERS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 38,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 195,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: teachers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (ctx, index) {
                        return TeacherCard(staff: teachers[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. SUB-WING (SKSBV) DROPDOWN PILL
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SKSBV',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 6. GALLERY SECTION
            Container(
              key: _galleryKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 38,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 2-Column Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.25,
                    children: List.generate(8, (i) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: Colors.black,
                                  height: 300,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.image, size: 64, color: Colors.white70),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Event Photo ${i + 1}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                color: Color((0xFFE2E8F0 + (i * 0x050505)) | 0xFF000000),
                                child: Center(
                                  child: Icon(Icons.photo_library_outlined, color: Colors.blue.shade300, size: 28),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Event ${i + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // 7. FOLLOW US & FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  const Text(
                    'FOLLOW US',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Social Media Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.play_arrow_rounded, const Color(0xFFFF0000)), // YouTube
                      const SizedBox(width: 14),
                      _buildSocialIcon(Icons.camera_alt_outlined, const Color(0xFFE1306C)), // Instagram
                      const SizedBox(width: 14),
                      _buildSocialIcon(Icons.chat_bubble_outline_rounded, const Color(0xFF25D366)), // WhatsApp
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contact Pills (Email & Phone)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mail_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              setting.email,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              setting.phone,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Accent Line
                  Container(
                    width: 40,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Copyright
                  Text(
                    '© ${setting.institutionName}. All Rights Reserved.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Developer credit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Developed by ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Text(
                        setting.developerCredit,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Version & Update Date
                  Text(
                    'Version: ${setting.versionText}\nLast Updated: ${setting.lastUpdatedText}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

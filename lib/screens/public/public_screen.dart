import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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

    // Faculty members directly from Firestore
    final teachers = provider.staffList;

    // Compute metrics directly from database
    final totalStudents = provider.totalStudents.toString();
    final totalTeachers = provider.totalStaff.toString();
    final maleCount = provider.students.where((s) => s.gender.toLowerCase() == 'male').length.toString();
    final femaleCount = provider.students.where((s) => s.gender.toLowerCase() == 'female').length.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          // App Bar: Desktop 3-zone SaaS Top Bar or Mobile Compact Bar
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(isDesktop ? 68 : 56),
            child: isDesktop
                ? _buildDesktopNavBar(context, setting)
                : _buildMobileNavBar(context, setting),
          ),

          // End Drawer for Mobile View
          endDrawer: isDesktop ? null : _buildMobileDrawer(context, setting),

          // Scrollable Page Content
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // 1. HERO SECTION (Split on Desktop, Stacked on Mobile)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroSurfaceGradient,
                    border: Border(bottom: BorderSide(color: AppColors.slate200)),
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 20,
                        vertical: isDesktop ? 54 : 28,
                      ),
                      child: isDesktop
                          ? _buildDesktopHero(context, setting, totalStudents, totalTeachers)
                          : _buildMobileHero(context, setting),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 2. STATS RIBBON (Tabular figures)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: LandingStatCard(
                                  title: 'Enrolled Students',
                                  count: totalStudents,
                                  icon: Icons.groups_rounded,
                                  accentColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: LandingStatCard(
                                  title: 'Faculty & Staff',
                                  count: totalTeachers,
                                  icon: Icons.co_present_rounded,
                                  accentColor: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: LandingStatCard(
                                  title: 'Male Students',
                                  count: maleCount,
                                  icon: Icons.person_rounded,
                                  accentColor: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: LandingStatCard(
                                  title: 'Female Students',
                                  count: femaleCount,
                                  icon: Icons.woman_rounded,
                                  accentColor: AppColors.info,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: LandingStatCard(
                                      title: 'Students',
                                      count: totalStudents,
                                      icon: Icons.groups_rounded,
                                      accentColor: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LandingStatCard(
                                      title: 'Teachers',
                                      count: totalTeachers,
                                      icon: Icons.co_present_rounded,
                                      accentColor: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: LandingStatCard(
                                      title: 'Male',
                                      count: maleCount,
                                      icon: Icons.person_rounded,
                                      accentColor: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LandingStatCard(
                                      title: 'Female',
                                      count: femaleCount,
                                      icon: Icons.woman_rounded,
                                      accentColor: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 48),

                // 3. ABOUT US SECTION
                Center(
                  child: Container(
                    key: _aboutKey,
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSectionHeader('About Our Institution', 'Heritage, values, and academic excellence'),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isDesktop ? 32 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.slate200),
                            boxShadow: const [
                              BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Text(
                            setting.aboutText.isNotEmpty
                                ? setting.aboutText
                                : 'Welcome to our institution. We provide comprehensive education and values-driven personal development for all students.',
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.slate700,
                              height: 1.7,
                              letterSpacing: 0.1,
                            ),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // 4. TEACHERS SECTION
                Center(
                  child: Container(
                    key: _teachersKey,
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                    child: Column(
                      children: [
                        _buildSectionHeader('Faculty & Instructors', 'Dedicated educators shaping the next generation'),
                        const SizedBox(height: 24),
                        teachers.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Faculty directory will be updated from Admin portal.',
                                    style: TextStyle(color: AppColors.slate400, fontSize: 13),
                                  ),
                                ),
                              )
                            : isDesktop
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: constraints.maxWidth > 1100 ? 4 : 3,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: teachers.length,
                                    itemBuilder: (ctx, idx) => TeacherCard(staff: teachers[idx]),
                                  )
                                : SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: teachers.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                                      itemBuilder: (ctx, index) => TeacherCard(staff: teachers[index]),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 5. SUB-WING DROPDOWN PILL
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 2))],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SKSBV WING',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.slate900, letterSpacing: 0.6),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.slate500),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // 6. GALLERY SECTION
                Center(
                  child: Container(
                    key: _galleryKey,
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                    child: Column(
                      children: [
                        _buildSectionHeader('Campus Gallery', 'Memories and milestones from institutional life'),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 4 : 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: 8,
                          itemBuilder: (ctx, i) {
                            return InkWell(
                              onTap: () => _showPhotoDialog(context, i + 1),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.slate200),
                                  boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: Color((0xFFE2E8F0 + (i * 0x050505)) | 0xFF000000),
                                      child: const Center(
                                        child: Icon(Icons.photo_library_outlined, color: AppColors.primary400, size: 30),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Campus View ${i + 1}',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // 7. MULTI-COLUMN ENTERPRISE FOOTER
                _buildFooter(context, setting, isDesktop),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== TOP NAVIGATION BARS ====================

  Widget _buildDesktopNavBar(BuildContext context, dynamic setting) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              // Application Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/icon.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.institutionName,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.slate900),
                  ),
                  Text(
                    'Reg: ${setting.regNo} • ${setting.place}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.slate500, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              // Navigation links
              _buildNavLink('Home', () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut)),
              _buildNavLink('About Us', () => _scrollToKey(_aboutKey)),
              _buildNavLink('Faculty', () => _scrollToKey(_teachersKey)),
              _buildNavLink('Gallery', () => _scrollToKey(_galleryKey)),
              const SizedBox(width: 24),
              // Portal Login Button
              ElevatedButton.icon(
                onPressed: () => SecureLoginModal.show(context),
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text('Access Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate700),
        ),
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context, dynamic setting) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/icon.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  setting.institutionName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.slate900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Reg: ${setting.regNo} | ${setting.place}',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.slate800, size: 24),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer(BuildContext context, dynamic setting) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.slate300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(setting.institutionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Reg: ${setting.regNo}', style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.primary),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                _scrollToKey(_aboutKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.co_present_outlined, color: AppColors.primary),
              title: const Text('Faculty'),
              onTap: () {
                Navigator.pop(context);
                _scrollToKey(_teachersKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: AppColors.primary),
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
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    SecureLoginModal.show(context);
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Login Portal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HERO SECTIONS ====================

  Widget _buildDesktopHero(BuildContext context, dynamic setting, String totalStudents, String totalTeachers) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Branding, Value Prop & Primary CTA
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verified Institution Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'OFFICIAL ACADEMIC PORTAL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary800, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Large Display Headline
              Text(
                setting.institutionName,
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              // Governance & Accreditation
              Text(
                'Run & Governed by ${setting.managementName}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Registration No: ${setting.regNo} • Location: ${setting.place}',
                style: const TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              // Action Buttons Row
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => SecureLoginModal.show(context),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Access Management Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: () => _scrollToKey(_aboutKey),
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: const Text('Learn More', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate800,
                      side: const BorderSide(color: AppColors.slate300),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Feature Chips
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildHeroChip(Icons.flash_on_rounded, 'Realtime Sync'),
                  _buildHeroChip(Icons.receipt_long_rounded, 'Atomic Receipts'),
                  _buildHeroChip(Icons.shield_outlined, 'Role-Based Access'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Right Column: Floating Crest Glass Card with Live Metric Badges
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
              boxShadow: const [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Institution Crest
                Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate200, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 48, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  setting.institutionName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                ),
                Text(
                  setting.place,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),
                // 2 Micro-Stat Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          totalStudents,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Text('Students', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                      ],
                    ),
                    Container(height: 28, width: 1, color: AppColors.slate200),
                    Column(
                      children: [
                        Text(
                          totalTeachers,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warning,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Text('Teachers', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.slate600)),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context, dynamic setting) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.slate200),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 40, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          setting.institutionName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900, letterSpacing: -0.4),
        ),
        const SizedBox(height: 6),
        Text(
          'Run by: ${setting.managementName}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Reg No: ${setting.regNo} | ${setting.place}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.slate500),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => SecureLoginModal.show(context),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Access Portal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ==================== SECTION HEADERS ====================

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate900, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.slate500),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ==================== PHOTO PREVIEW DIALOG ====================

  void _showPhotoDialog(BuildContext context, int photoIndex) {
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
                    'Campus Event Photo $photoIndex',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ENTERPRISE FOOTER ====================

  Widget _buildFooter(BuildContext context, dynamic setting, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20, vertical: 36),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: Brand & Place
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.slate300)),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 10),
                              Text(setting.institutionName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Registration Number: ${setting.regNo}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                          Text('Location: ${setting.place}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                          const SizedBox(height: 6),
                          Text('Management: ${setting.managementName}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Col 2: Quick Links
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('QUICK NAVIGATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          InkWell(onTap: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut), child: const Text('Home Overview', style: TextStyle(fontSize: 13, color: AppColors.slate600))),
                          const SizedBox(height: 6),
                          InkWell(onTap: () => _scrollToKey(_aboutKey), child: const Text('About Institution', style: TextStyle(fontSize: 13, color: AppColors.slate600))),
                          const SizedBox(height: 6),
                          InkWell(onTap: () => _scrollToKey(_teachersKey), child: const Text('Faculty Directory', style: TextStyle(fontSize: 13, color: AppColors.slate600))),
                          const SizedBox(height: 6),
                          InkWell(onTap: () => _scrollToKey(_galleryKey), child: const Text('Campus Gallery', style: TextStyle(fontSize: 13, color: AppColors.slate600))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Col 3: Contact & Channels
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CONTACT & SOCIAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          Text('Email: ${setting.email}', style: const TextStyle(fontSize: 13, color: AppColors.slate600)),
                          const SizedBox(height: 4),
                          Text('Phone: ${setting.phone}', style: const TextStyle(fontSize: 13, color: AppColors.slate600)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildSocialIcon(Icons.play_arrow_rounded, const Color(0xFFFF0000)),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.camera_alt_outlined, const Color(0xFFE1306C)),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.chat_bubble_outline_rounded, const Color(0xFF25D366)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text(setting.institutionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Reg: ${setting.regNo} | ${setting.place}', style: const TextStyle(fontSize: 11, color: AppColors.slate500)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.play_arrow_rounded, const Color(0xFFFF0000)),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.camera_alt_outlined, const Color(0xFFE1306C)),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.chat_bubble_outline_rounded, const Color(0xFF25D366)),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '© ${setting.institutionName}. All Rights Reserved. • Version: ${setting.versionText}',
                style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Developed by ', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                  Text(
                    setting.developerCredit,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate800, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ],
          ),
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
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

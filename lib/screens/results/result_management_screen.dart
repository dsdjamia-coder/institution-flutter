import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/exam_result.dart';
import '../../models/student.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ResultManagementScreen extends StatefulWidget {
  const ResultManagementScreen({super.key});

  @override
  State<ResultManagementScreen> createState() => _ResultManagementScreenState();
}

class _ResultManagementScreenState extends State<ResultManagementScreen> {
  int _currentIndex = 0;
  String _selectedExam = 'Annual Exam 2026';
  String? _selectedClass;
  bool _isPublishEnabled = true;
  bool _isSaving = false;

  final Map<String, TextEditingController> _markControllers = {};

  final List<String> _exams = [
    'Annual Exam 2026',
    'Mid-Term Exam 2026',
    'Term 1 Exam 2025',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<InstitutionProvider>();
    if (provider.classes.isNotEmpty) {
      _selectedClass = provider.classes.first;
    }
  }

  @override
  void dispose() {
    for (final c in _markControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF059669);
      case 'B':
        return const Color(0xFF2563EB);
      case 'C':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFFEF4444);
    }
  }

  Color _getGradeBgColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFFECFDF5);
      case 'B':
        return const Color(0xFFEFF6FF);
      case 'C':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFFEF2F2);
    }
  }

  void _showPromotionDialog(BuildContext context) {
    final provider = context.read<InstitutionProvider>();
    String fromCls = _selectedClass ?? (provider.classes.isNotEmpty ? provider.classes.first : 'Class 1');
    String toCls = 'Class 2';
    bool isTerminalAlumni = fromCls == 'Class 12' || fromCls == provider.classes.last;

    final targetOptions = [
      ...provider.classes,
      'Alumni (Graduated)',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.upgrade_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Annual Academic Promotion', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advance passing students to the subsequent academic grade or graduate terminal final-year students directly into the permanent Alumni Register.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fromCls,
                decoration: InputDecoration(
                  labelText: 'From Current Class',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    fromCls = val!;
                    final idx = provider.classes.indexOf(fromCls);
                    if (idx < provider.classes.length - 1) {
                      toCls = provider.classes[idx + 1];
                      isTerminalAlumni = false;
                    } else {
                      toCls = 'Alumni (Graduated)';
                      isTerminalAlumni = true;
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: toCls,
                decoration: InputDecoration(
                  labelText: 'Promote To Class',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                items: targetOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    toCls = val!;
                    isTerminalAlumni = toCls.contains('Alumni');
                  });
                },
              ),
              const SizedBox(height: 14),
              if (isTerminalAlumni)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school_rounded, color: Color(0xFF9333EA), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Graduating students will be permanently archived in the Alumni Register with their graduation year preserved.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF7E22CE), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await provider.promoteClass(fromCls, isTerminalAlumni ? 'Alumni' : toCls, isTerminalAlumni);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Class $fromCls promoted successfully to ${isTerminalAlumni ? "Alumni" : toCls}!'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Execute Promotion'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final classStudents = provider.activeStudents
        .where((s) => s.studentClass == _selectedClass)
        .toList();
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return AdaptivePortalScaffold(
      portalId: 'results',
      portalTitle: 'Result Management System',
      portalSubtitle: 'Marks entry, live grading, report cards, and promotion engine',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      headerActions: [
        ElevatedButton.icon(
          onPressed: () => _showPromotionDialog(context),
          icon: const Icon(Icons.upgrade_rounded, size: 16),
          label: const Text('Promote Cohort', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
      tabs: [
        // TAB 1: MARKS ENTRY
        PortalTabItem(
          id: 'marks',
          label: 'Marks Entry',
          icon: Icons.edit_note_rounded,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildControlsCard(provider),
                const SizedBox(height: 16),
                _buildPublishStatusBanner(),
                const SizedBox(height: 20),
                _buildCohortStatsRibbon(classStudents),
                const SizedBox(height: 20),
                _buildCandidatesList(classStudents, isDesktop),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMarks,
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    _isSaving ? 'Saving Marks to Cloud...' : 'Save & Publish Exam Results',
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
          ),
        ),

        // TAB 2: PROMOTION & GRADUATION ENGINE
        PortalTabItem(
          id: 'promotion',
          label: 'Class Promotion',
          icon: Icons.upgrade_rounded,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.upgrade_rounded, color: Color(0xFF2563EB), size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ANNUAL ACADEMIC PROMOTION ENGINE',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
                            ),
                            Text(
                              'Cohort progression and terminal graduation management',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 28, color: Color(0xFFE2E8F0)),
                    const Text(
                      'This workflow elevates all active students in a cohort to their next academic grade at the completion of an academic session. If promoting the final terminal class (e.g. Class 12), students will automatically transition into the permanent Alumni Register.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showPromotionDialog(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Launch Promotion Workflow', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== CONTROLS CARD ====================
  Widget _buildControlsCard(InstitutionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedExam,
              decoration: InputDecoration(
                labelText: 'Select Examination',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _exams.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedExam = val ?? _exams.first),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: InputDecoration(
                labelText: 'Target Class Cohort',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedClass = val),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PUBLISH STATUS BANNER ====================
  Widget _buildPublishStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isPublishEnabled ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isPublishEnabled ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: _isPublishEnabled ? const Color(0xFF059669) : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Publish on Student Portal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  Text(
                    _isPublishEnabled ? 'Published • Visible to students & parents online' : 'Draft Mode • Hidden from student portal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isPublishEnabled ? const Color(0xFF059669) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isPublishEnabled,
            onChanged: (val) => setState(() => _isPublishEnabled = val),
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  // ==================== COHORT STATS RIBBON ====================
  Widget _buildCohortStatsRibbon(List<Student> classStudents) {
    double totalMarks = 0;
    int enteredCount = 0;
    double maxMark = 0;

    for (final st in classStudents) {
      final ctrl = _markControllers[st.id];
      if (ctrl != null && ctrl.text.isNotEmpty) {
        final m = double.tryParse(ctrl.text) ?? 0;
        totalMarks += m;
        enteredCount++;
        if (m > maxMark) maxMark = m;
      }
    }

    final avg = enteredCount > 0 ? (totalMarks / enteredCount) : 0.0;

    return Row(
      children: [
        _buildStatCard(
          title: 'CANDIDATES',
          value: classStudents.length.toString(),
          accentColor: const Color(0xFF2563EB),
          icon: Icons.groups_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'MARKS ENTERED',
          value: '$enteredCount / ${classStudents.length}',
          accentColor: const Color(0xFF0D9488),
          icon: Icons.assignment_turned_in_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'CLASS AVERAGE',
          value: '${avg.toStringAsFixed(1)}%',
          accentColor: const Color(0xFFD97706),
          icon: Icons.analytics_rounded,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'TOP MARK',
          value: maxMark.toStringAsFixed(0),
          accentColor: const Color(0xFF059669),
          icon: Icons.star_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                ),
                Icon(icon, size: 14, color: accentColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CANDIDATES LIST ====================
  Widget _buildCandidatesList(List<Student> classStudents, bool isDesktop) {
    if (classStudents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_off_rounded, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                'No active students enrolled in ${_selectedClass ?? "this class"}.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) {
        final st = classStudents[idx];
        final ctrl = _markControllers.putIfAbsent(st.id, () => TextEditingController(text: ''));
        final mark = double.tryParse(ctrl.text) ?? 0.0;
        final grade = ExamResult.calculateGrade(mark);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  '#${st.adm}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(st.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text(
                      'Roll: ${st.roll.isNotEmpty ? st.roll : "-"} • ${st.gender}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Marks Input
              Container(
                width: 90,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: 'Marks',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              // Grade Pill
              Container(
                width: 44,
                height: 38,
                decoration: BoxDecoration(
                  color: _getGradeBgColor(grade),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getGradeColor(grade).withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _getGradeColor(grade),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== SAVE MARKS ====================
  void _saveMarks() async {
    final provider = context.read<InstitutionProvider>();
    final classStudents = provider.activeStudents
        .where((s) => s.studentClass == _selectedClass)
        .toList();

    setState(() => _isSaving = true);

    for (final st in classStudents) {
      final ctrl = _markControllers[st.id];
      final mark = double.tryParse(ctrl?.text ?? '') ?? 0.0;
      final grade = ExamResult.calculateGrade(mark);

      final result = ExamResult(
        id: '${_selectedExam}_${st.id}',
        examId: _selectedExam,
        studentId: st.id,
        admissionNo: st.adm,
        studentName: st.name,
        studentClass: st.studentClass,
        academicYear: provider.setting.activeAcademicYear,
        marks: {'General': mark},
        total: mark,
        percentage: mark,
        grade: grade,
        published: _isPublishEnabled,
      );

      await provider.saveExamResult(result);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exam marks saved and published successfully!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
  }
}

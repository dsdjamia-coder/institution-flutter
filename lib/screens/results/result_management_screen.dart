import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/exam_result.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';

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
              Icon(Icons.upgrade, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Annual Academic Promotion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a source class to advance passing students. If graduating terminal year (e.g. Class 12), select Alumni to archive their permanent graduation records.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fromCls,
                decoration: const InputDecoration(labelText: 'From Current Class', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(labelText: 'Promote To Class', border: OutlineInputBorder()),
                items: targetOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    toCls = val!;
                    isTerminalAlumni = toCls.contains('Alumni');
                  });
                },
              ),
              const SizedBox(height: 12),
              if (isTerminalAlumni)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school, color: Color(0xFF9333EA), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🎓 Students will graduate into the Alumni Register with their completion record preserved.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7E22CE), fontWeight: FontWeight.w600),
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
                      content: Text('Class $fromCls promoted successfully to ${isTerminalAlumni ? 'Alumni' : toCls}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
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

    return AdaptivePortalScaffold(
      portalTitle: 'Result Management System',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      headerActions: [
        ElevatedButton.icon(
          onPressed: () => _showPromotionDialog(context),
          icon: const Icon(Icons.upgrade_rounded, size: 16),
          label: const Text('Promote Cohort', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Controls Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedExam,
                          decoration: InputDecoration(
                            labelText: 'Select Examination',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            labelText: 'Target Class',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => _selectedClass = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Publishing Status Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Publish on Student Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            _isPublishEnabled ? 'Results are visible to students' : 'Results are hidden (Draft)',
                            style: TextStyle(fontSize: 11, color: _isPublishEnabled ? Colors.green : Colors.grey),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isPublishEnabled,
                        onChanged: (val) => setState(() => _isPublishEnabled = val),
                        activeColor: Colors.blue.shade600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Students Mark Input Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CANDIDATES (${classStudents.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    Text(
                      _selectedClass ?? '',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (classStudents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.person_off, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No active students registered in ${_selectedClass ?? "this class"}.', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final st = classStudents[idx];
                      final ctrl = _markControllers.putIfAbsent(st.id, () => TextEditingController(text: ''));

                      final currentMark = double.tryParse(ctrl.text) ?? 0.0;
                      final grade = ExamResult.calculateGrade(currentMark);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                '#${st.adm}',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Roll: ${st.roll} • ${st.gender}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Marks',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.indigo.shade200),
                              ),
                              child: Center(
                                child: Text(grade, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _saveMarks,
                  icon: const Icon(Icons.save),
                  label: const Text('Save & Update Results'),
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

        // TAB 2: PROMOTION & GRADUATION ENGINE
        PortalTabItem(
          id: 'promotion',
          label: 'Class Promotion',
          icon: Icons.upgrade_rounded,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upgrade_rounded, color: Color(0xFF2563EB), size: 24),
                      SizedBox(width: 10),
                      Text('ANNUAL PROMOTION & ALUMNI ENGINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Promote passing students to the subsequent academic grade or graduate terminal final-year students directly into the permanent Alumni Register.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showPromotionDialog(context),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Launch Class Promotion Workflow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveMarks() async {
    final provider = context.read<InstitutionProvider>();
    final classStudents = provider.activeStudents
        .where((s) => s.studentClass == _selectedClass)
        .toList();

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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam marks saved and published successfully!')),
      );
    }
  }
}

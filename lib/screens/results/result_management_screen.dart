import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/exam_result.dart';

class ResultManagementScreen extends StatefulWidget {
  const ResultManagementScreen({super.key});

  @override
  State<ResultManagementScreen> createState() => _ResultManagementScreenState();
}

class _ResultManagementScreenState extends State<ResultManagementScreen> {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final classStudents = provider.students
        .where((s) => s.studentClass == _selectedClass && s.status == 'Active')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Result Management System',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
        ),
      ),
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
            const SizedBox(height: 16),

            // Publishing Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Publish Results to Student Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isPublishEnabled,
                    activeColor: Colors.blue.shade600,
                    onChanged: (v) => setState(() => _isPublishEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Marks Entry Table
            classStudents.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No active students found in this class.')))
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: classStudents.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (ctx, idx) {
                        final st = classStudents[idx];
                        if (!_markControllers.containsKey(st.id)) {
                          _markControllers[st.id] = TextEditingController(text: '85');
                        }
                        final ctrl = _markControllers[st.id]!;
                        final mark = double.tryParse(ctrl.text) ?? 0.0;
                        final grade = ExamResult.calculateGrade(mark);

                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Text('#${st.adm}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Roll: ${st.roll} • Class: ${st.studentClass}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: ctrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    labelText: 'Mark (100)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 44,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.indigo.shade200),
                                ),
                                child: Text(grade, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
    );
  }

  void _saveMarks() async {
    final provider = context.read<InstitutionProvider>();
    final classStudents = provider.students
        .where((s) => s.studentClass == _selectedClass && s.status == 'Active')
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

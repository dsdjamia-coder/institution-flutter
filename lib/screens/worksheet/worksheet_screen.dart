import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class WorksheetScreen extends StatefulWidget {
  const WorksheetScreen({super.key});

  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen> {
  int _currentIndex = 0;
  String _selectedClassFilter = 'ALL';
  String _studentSearchQuery = '';
  String _alumniYearFilter = 'ALL';
  bool _isTableView = true;

  // Excel mini-grid state
  final int _cols = 6;
  final int _rows = 20;
  late List<List<String>> _gridData;
  int _selectedRow = 0;
  int _selectedCol = 0;
  final TextEditingController _formulaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    _gridData = List.generate(_rows, (r) => List.generate(_cols, (c) => ''));
    _gridData[0] = ['Adm No', 'Student Name', 'Class', 'Gender', 'Guardian', 'Phone'];
    _formulaController.text = _gridData[0][0];
  }

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();
    final activeStudents = provider.activeStudents;
    final alumniStudents = provider.alumniStudents;
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    // Distinct alumni graduation years
    final alumniYears = [
      'ALL',
      ...alumniStudents.map((a) => a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear).toSet()
    ];

    return AdaptivePortalScaffold(
      portalId: 'worksheet',
      portalTitle: 'Class Worksheet & Registers',
      portalSubtitle: 'Demographics, rosters, alumni archives, and spreadsheet canvas',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      tabs: [
        // TAB 1: CLASS SUMMARY
        PortalTabItem(
          id: 'summary',
          label: 'Class Summary',
          icon: Icons.bar_chart_rounded,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActiveClassesSummary(provider, activeStudents),
                const SizedBox(height: 24),
                _buildAlumniSummary(alumniStudents, alumniYears),
              ],
            ),
          ),
        ),

        // TAB 2: STUDENTS REGISTER
        PortalTabItem(
          id: 'register',
          label: 'Students Register',
          icon: Icons.format_list_bulleted_rounded,
          body: _buildStudentsRegister(provider, activeStudents, isDesktop),
        ),

        // TAB 3: ALUMNI REGISTER
        PortalTabItem(
          id: 'alumni',
          label: 'Alumni Register',
          icon: Icons.school_rounded,
          body: _buildAlumniRegister(alumniStudents, alumniYears, isDesktop),
        ),

        // TAB 4: STAFF DIRECTORY
        PortalTabItem(
          id: 'staff',
          label: 'Staff Directory',
          icon: Icons.people_alt_rounded,
          body: _buildStaffDirectory(provider),
        ),

        // TAB 5: WORKSHEET CANVAS (EXCEL)
        PortalTabItem(
          id: 'canvas',
          label: 'Worksheet Canvas',
          icon: Icons.table_chart_rounded,
          body: _buildWorksheetCanvas(activeStudents),
        ),
      ],
    );
  }

  // ==================== TAB 1: SUMMARY PANELS ====================
  Widget _buildActiveClassesSummary(InstitutionProvider provider, List<Student> activeStudents) {
    int totalBoys = 0;
    int totalGirls = 0;

    final rows = provider.classes.map((cls) {
      final cohort = activeStudents.where((s) => s.studentClass == cls).toList();
      final boys = cohort.where((s) => s.gender.toLowerCase() == 'male').length;
      final girls = cohort.where((s) => s.gender.toLowerCase() == 'female').length;
      totalBoys += boys;
      totalGirls += girls;

      return DataRow(
        cells: [
          DataCell(Text(cls, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          DataCell(Text(
            boys.toString(),
            style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          )),
          DataCell(Text(
            girls.toString(),
            style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          )),
          DataCell(Text(
            cohort.length.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE CLASSES DEMOGRAPHIC SUMMARY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Gender ratio & cohort enrollment across active divisions',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    'Total Active: ${provider.totalActiveStudents}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Boys', style: TextStyle(fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Girls', style: TextStyle(fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Total Students', style: TextStyle(fontWeight: FontWeight.w800))),
              ],
              rows: [
                ...rows,
                // Total Summary Footer Row
                DataRow(
                  color: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  cells: [
                    const DataCell(Text('ALL CLASSES TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
                    DataCell(Text(
                      totalBoys.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()]),
                    )),
                    DataCell(Text(
                      totalGirls.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()]),
                    )),
                    DataCell(Text(
                      (totalBoys + totalGirls).toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniSummary(List<Student> alumniStudents, List<String> alumniYears) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALUMNI SUMMARY (GRADUATED COHORTS)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B21A8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Historical graduate batches permanently archived',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF3E8FF)),
                  ),
                  child: Text(
                    'Total Alumni: ${alumniStudents.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9333EA),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (alumniStudents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No graduated alumni records recorded yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFFAF5FF)),
                columns: const [
                  DataColumn(label: Text('Graduated Batch', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Boys', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Girls', style: TextStyle(fontWeight: FontWeight.w800))),
                  DataColumn(label: Text('Total Graduated', style: TextStyle(fontWeight: FontWeight.w800))),
                ],
                rows: alumniYears.where((y) => y != 'ALL').map((year) {
                  final cohort = alumniStudents
                      .where((a) => (a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear) == year)
                      .toList();
                  final boys = cohort.where((a) => a.gender.toLowerCase() == 'male').length;
                  final girls = cohort.where((a) => a.gender.toLowerCase() == 'female').length;

                  return DataRow(
                    cells: [
                      DataCell(Text('Batch $year', style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(boys.toString(), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]))),
                      DataCell(Text(girls.toString(), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]))),
                      DataCell(Text(
                        cohort.length.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9333EA),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== TAB 2: STUDENTS REGISTER ====================
  Widget _buildStudentsRegister(
    InstitutionProvider provider,
    List<Student> activeStudents,
    bool isDesktop,
  ) {
    final filtered = activeStudents.where((s) {
      final matchesClass = _selectedClassFilter == 'ALL' || s.studentClass == _selectedClassFilter;
      final matchesQuery = _studentSearchQuery.isEmpty ||
          s.name.toLowerCase().contains(_studentSearchQuery.toLowerCase()) ||
          s.adm.contains(_studentSearchQuery);
      return matchesClass && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Controls Bar
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search active students by Name or Adm #...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => setState(() => _studentSearchQuery = val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedClassFilter,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('All Classes')),
                    ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setState(() => _selectedClassFilter = val ?? 'ALL'),
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                IconButton(
                  tooltip: _isTableView ? 'Switch to Card View' : 'Switch to Table View',
                  icon: Icon(_isTableView ? Icons.grid_view_rounded : Icons.table_rows_rounded),
                  onPressed: () => setState(() => _isTableView = !_isTableView),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Roster Content
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No active student records found.'))
              : isDesktop && _isTableView
                  ? _buildStudentsDataTable(filtered)
                  : _buildStudentsCardList(filtered),
        ),
      ],
    );
  }

  Widget _buildStudentsDataTable(List<Student> students) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('Adm #', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Roll', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Guardian / Father', style: TextStyle(fontWeight: FontWeight.w800))),
              DataColumn(label: Text('Phone / Mobile', style: TextStyle(fontWeight: FontWeight.w800))),
            ],
            rows: students.map((s) {
              return DataRow(
                cells: [
                  DataCell(Text(s.adm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                  DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(s.studentClass)),
                  DataCell(Text(s.roll.isNotEmpty ? s.roll : '-')),
                  DataCell(Text(s.gender)),
                  DataCell(Text(s.father.isNotEmpty ? s.father : '-')),
                  DataCell(Text(s.mobile.isNotEmpty ? s.mobile : '-')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsCardList(List<Student> students) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) {
        final s = students[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppColors.cardShadow,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                '#${s.adm}',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
              ),
            ),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            subtitle: Text(
              '${s.studentClass} • ${s.gender} • Guardian: ${s.father.isNotEmpty ? s.father : "-"} • Ph: ${s.mobile.isNotEmpty ? s.mobile : "-"}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ),
        );
      },
    );
  }

  // ==================== TAB 3: ALUMNI REGISTER ====================
  Widget _buildAlumniRegister(
    List<Student> alumniStudents,
    List<String> alumniYears,
    bool isDesktop,
  ) {
    final filtered = alumniStudents.where((a) {
      if (_alumniYearFilter == 'ALL') return true;
      final year = a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear;
      return year == _alumniYearFilter;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.school_rounded, color: Color(0xFF9333EA), size: 20),
              const SizedBox(width: 8),
              const Text('Graduation Cohort:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _alumniYearFilter,
                items: alumniYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y == 'ALL' ? 'All Batches' : 'Batch $y')))
                    .toList(),
                onChanged: (val) => setState(() => _alumniYearFilter = val ?? 'ALL'),
              ),
              const Spacer(),
              Text('${filtered.length} Alumni Records', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 12),
                      Text('No graduated students (Alumni) recorded yet.', style: TextStyle(color: Color(0xFF94A3B8))),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final a = filtered[idx];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFAF5FF),
                          child: Icon(Icons.school_rounded, color: Color(0xFF9333EA), size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(a.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('ALUMNI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF7E22CE))),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Adm: #${a.adm} • Completed: ${a.completedClass.isNotEmpty ? a.completedClass : "Course"} • Batch: ${a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear} • Contact: ${a.mobile}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==================== TAB 4: STAFF DIRECTORY ====================
  Widget _buildStaffDirectory(InstitutionProvider provider) {
    if (provider.staffList.isEmpty) {
      return const Center(child: Text('No faculty or ustads registered yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.staffList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final st = provider.staffList[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppColors.cardShadow,
          ),
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
                Text(st.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    st.designation.toUpperCase(),
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Role: ${st.role} • Assigned Class: ${st.assignedClass.isNotEmpty ? st.assignedClass : "All"} • Ph: ${st.phone}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ),
        );
      },
    );
  }

  // ==================== TAB 5: WORKSHEET CANVAS (EXCEL) ====================
  Widget _buildWorksheetCanvas(List<Student> activeStudents) {
    return Column(
      children: [
        // Ribbon Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _initGrid();
                    for (int i = 0; i < activeStudents.length && i < _rows - 1; i++) {
                      final s = activeStudents[i];
                      _gridData[i + 1] = [s.adm, s.name, s.studentClass, s.gender, s.father, s.mobile];
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auto-filled active students into worksheet!')),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded, size: 16),
                label: const Text('Auto-Fill Students', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A4 Print preview ready.')),
                  );
                },
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text('Print A4', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _initGrid());
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Formula Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  '${String.fromCharCode(65 + _selectedCol)}${_selectedRow + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              const Text('fx', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _formulaController,
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'Cell formula/value'),
                  onChanged: (val) {
                    setState(() {
                      _gridData[_selectedRow][_selectedCol] = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Interactive A4 Grid
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(140),
                border: TableBorder.all(color: const Color(0xFFCBD5E1)),
                children: List.generate(_rows, (r) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: r == 0 ? const Color(0xFFF8FAFC) : Colors.white,
                    ),
                    children: List.generate(_cols, (c) {
                      final isSelected = _selectedRow == r && _selectedCol == c;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedRow = r;
                            _selectedCol = c;
                            _formulaController.text = _gridData[r][c];
                          });
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : null,
                            border: isSelected ? Border.all(color: const Color(0xFF2563EB), width: 2) : null,
                          ),
                          child: Text(
                            _gridData[r][c],
                            style: TextStyle(
                              fontWeight: r == 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

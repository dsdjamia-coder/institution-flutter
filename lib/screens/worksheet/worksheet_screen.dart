import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../models/student.dart';
import '../../widgets/layout/adaptive_portal_scaffold.dart';

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

  // Excel mini-grid state
  final int _cols = 6;
  final int _rows = 15;
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

    // Distinct alumni graduation years
    final alumniYears = ['ALL', ...alumniStudents.map((a) => a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear).toSet()];

    return AdaptivePortalScaffold(
      portalTitle: 'Class Worksheet & Registers',
      initialIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      tabs: [
        PortalTabItem(
          id: 'summary',
          label: 'Class Summary',
          icon: Icons.bar_chart_rounded,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Class Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Classes Summary',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Total Active: ${provider.totalActiveStudents}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Boys', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Girls', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.classes.map((cls) {
                            final cohort = activeStudents.where((s) => s.studentClass == cls).toList();
                            final boys = cohort.where((s) => s.gender.toLowerCase() == 'male').length;
                            final girls = cohort.where((s) => s.gender.toLowerCase() == 'female').length;

                            return DataRow(
                              cells: [
                                DataCell(Text(cls, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(boys.toString())),
                                DataCell(Text(girls.toString())),
                                DataCell(Text(
                                  cohort.length.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Independent Alumni Summary Table (Grouped by Graduated Academic Year)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Alumni Summary (Graduated Cohorts)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF6B21A8)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Total Alumni: ${alumniStudents.length}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (alumniStudents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No graduated alumni records recorded yet.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFFAF5FF)),
                            columns: const [
                              DataColumn(label: Text('Graduated Year', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Boys', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Girls', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: alumniYears.where((y) => y != 'ALL').map((year) {
                              final cohort = alumniStudents
                                  .where((a) => (a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear) == year)
                                  .toList();
                              final boys = cohort.where((a) => a.gender.toLowerCase() == 'male').length;
                              final girls = cohort.where((a) => a.gender.toLowerCase() == 'female').length;

                              return DataRow(
                                cells: [
                                  DataCell(Text('Batch $year', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(boys.toString())),
                                  DataCell(Text(girls.toString())),
                                  DataCell(Text(
                                    cohort.length.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. STUDENTS REGISTER (Active Students with Search, Filters & A4 Card List)
        PortalTabItem(
          id: 'register',
          label: 'Students Register',
          icon: Icons.format_list_bulleted_rounded,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search active students...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) => setState(() => _studentSearchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
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
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: activeStudents.where((s) {
                    final matchesClass = _selectedClassFilter == 'ALL' || s.studentClass == _selectedClassFilter;
                    final matchesQuery = _studentSearchQuery.isEmpty ||
                        s.name.toLowerCase().contains(_studentSearchQuery.toLowerCase()) ||
                        s.adm.contains(_studentSearchQuery);
                    return matchesClass && matchesQuery;
                  }).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final filtered = activeStudents.where((s) {
                      final matchesClass = _selectedClassFilter == 'ALL' || s.studentClass == _selectedClassFilter;
                      final matchesQuery = _studentSearchQuery.isEmpty ||
                          s.name.toLowerCase().contains(_studentSearchQuery.toLowerCase()) ||
                          s.adm.contains(_studentSearchQuery);
                      return matchesClass && matchesQuery;
                    }).toList();

                    final s = filtered[idx];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            '#${s.adm}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: Text(
                          '${s.studentClass} • ${s.gender} • Father: ${s.father.isNotEmpty ? s.father : '-'} • Ph: ${s.mobile}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 3. DEDICATED ALUMNI REGISTER TAB
        PortalTabItem(
          id: 'alumni',
          label: 'Alumni Register',
          icon: Icons.school_rounded,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                color: Colors.white,
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    const Text('Graduation Batch: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _alumniYearFilter,
                      items: alumniYears.map((y) => DropdownMenuItem(value: y, child: Text(y == 'ALL' ? 'All Batches' : 'Batch $y'))).toList(),
                      onChanged: (val) => setState(() => _alumniYearFilter = val ?? 'ALL'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: alumniStudents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No graduated students (Alumni) recorded yet.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: alumniStudents.where((a) {
                          if (_alumniYearFilter == 'ALL') return true;
                          final year = a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear;
                          return year == _alumniYearFilter;
                        }).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final list = alumniStudents.where((a) {
                            if (_alumniYearFilter == 'ALL') return true;
                            final year = a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear;
                            return year == _alumniYearFilter;
                          }).toList();

                          final a = list[idx];
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE9D5FF)),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFFAF5FF),
                                child: Icon(Icons.school, color: Color(0xFF9333EA), size: 20),
                              ),
                              title: Row(
                                children: [
                                  Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('ALUMNI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Adm: #${a.adm} • Completed: ${a.completedClass.isNotEmpty ? a.completedClass : 'Course'} • Batch: ${a.graduatedYear.isNotEmpty ? a.graduatedYear : a.academicYear} • Contact: ${a.mobile}',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // 4. STAFF DIRECTORY
        PortalTabItem(
          id: 'staff',
          label: 'Staff Directory',
          icon: Icons.people_alt_rounded,
          body: provider.staffList.isEmpty
              ? const Center(child: Text('No faculty or ustads registered yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.staffList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final st = provider.staffList[idx];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                            Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                st.designation.toUpperCase(),
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('Role: ${st.role} • Assigned Class: ${st.assignedClass.isNotEmpty ? st.assignedClass : 'All'} • Ph: ${st.phone}'),
                      ),
                    );
                  },
                ),
        ),

        // 5. WORKSHEET CANVAS (EXCEL-LIKE MINI WORKSPACE)
        PortalTabItem(
          id: 'canvas',
          label: 'Worksheet Canvas (Excel)',
          icon: Icons.table_chart_rounded,
          body: Column(
            children: [
              // Ribbon Toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Populate active students into grid
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
                      icon: const Icon(Icons.flash_on, size: 16),
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
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print A4', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _initGrid());
                      },
                      icon: const Icon(Icons.refresh, size: 16),
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
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';

class WorksheetScreen extends StatefulWidget {
  const WorksheetScreen({super.key});

  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedClassFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstitutionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Class Worksheet & Registers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          indicatorColor: Colors.blue.shade700,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics, size: 18), text: 'Class Summary'),
            Tab(icon: Icon(Icons.list_alt, size: 18), text: 'Students Register'),
            Tab(icon: Icon(Icons.school, size: 18), text: 'Alumni Register'),
            Tab(icon: Icon(Icons.badge, size: 18), text: 'Staff Directory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. CLASS SUMMARY
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Boys', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Girls', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Active', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: provider.classes.map((cls) {
                final clsStudents = provider.students.where((s) => s.studentClass == cls && s.status == 'Active');
                final boys = clsStudents.where((s) => s.gender == 'Male').length;
                final girls = clsStudents.where((s) => s.gender == 'Female').length;

                return DataRow(
                  cells: [
                    DataCell(Text(cls, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(boys.toString())),
                    DataCell(Text(girls.toString())),
                    DataCell(Text(clsStudents.length.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  ],
                );
              }).toList(),
            ),
          ),

          // 2. STUDENTS REGISTER
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Filter Class: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedClassFilter,
                      items: [
                        const DropdownMenuItem(value: 'ALL', child: Text('All Classes')),
                        ...provider.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                      ],
                      onChanged: (val) => setState(() => _selectedClassFilter = val ?? 'ALL'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.students.where((s) => (_selectedClassFilter == 'ALL' || s.studentClass == _selectedClassFilter) && s.status == 'Active').length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, idx) {
                    final filtered = provider.students.where((s) => (_selectedClassFilter == 'ALL' || s.studentClass == _selectedClassFilter) && s.status == 'Active').toList();
                    final s = filtered[idx];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text('#${s.adm}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Class: ${s.studentClass} • Father: ${s.father.isNotEmpty ? s.father : '-'} • Ph: ${s.mobile}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. ALUMNI REGISTER
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...provider.students.where((s) => s.status == 'Alumni' || s.studentClass.toLowerCase() == 'alumni').map((alumni) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.purple),
                    title: Text(alumni.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Adm: #${alumni.adm} • Completed Course'),
                  ),
                );
              }),
              if (!provider.students.any((s) => s.status == 'Alumni' || s.studentClass.toLowerCase() == 'alumni'))
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No alumni records yet.'))),
            ],
          ),

          // 4. STAFF DIRECTORY
          provider.staffList.isEmpty
              ? const Center(child: Text('No staff registered yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.staffList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final st = provider.staffList[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: const Icon(Icons.badge, color: Colors.indigo)),
                        title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${st.role} • Class: ${st.assignedClass.isNotEmpty ? st.assignedClass : 'All'} • ${st.phone}'),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

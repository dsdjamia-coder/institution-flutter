import 'package:flutter/material.dart';
import '../models/student.dart';

class CompoundStudentSearch extends StatefulWidget {
  final List<Student> students;
  final String? selectedClass;
  final Student? selectedStudent;
  final ValueChanged<Student?> onStudentSelected;
  final String hintText;

  const CompoundStudentSearch({
    super.key,
    required this.students,
    this.selectedClass,
    this.selectedStudent,
    required this.onStudentSelected,
    this.hintText = 'Search by Name or Admission No...',
  });

  @override
  State<CompoundStudentSearch> createState() => _CompoundStudentSearchState();
}

class _CompoundStudentSearchState extends State<CompoundStudentSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  List<Student> _filtered = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedStudent != null) {
      _controller.text = widget.selectedStudent!.compoundIdentity;
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _filterStudents(_controller.text);
        setState(() => _isDropdownOpen = true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CompoundStudentSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStudent != oldWidget.selectedStudent) {
      if (widget.selectedStudent != null) {
        _controller.text = widget.selectedStudent!.compoundIdentity;
      } else {
        _controller.clear();
      }
    }
  }

  void _filterStudents(String query) {
    final q = query.trim().toLowerCase();
    final pool = widget.students.where((s) {
      if (widget.selectedClass != null &&
          widget.selectedClass != 'ALL' &&
          widget.selectedClass!.isNotEmpty) {
        if (s.studentClass != widget.selectedClass) return false;
      }
      return true;
    }).toList();

    if (q.isEmpty) {
      _filtered = pool.take(8).toList();
    } else {
      _filtered = pool.where((s) {
        final nameMatch = s.name.toLowerCase().contains(q);
        final admMatch = s.adm.toLowerCase().contains(q);
        final fatherMatch = s.father.toLowerCase().contains(q);
        final phoneMatch = s.mobile.contains(q);
        return nameMatch || admMatch || fatherMatch || phoneMatch;
      }).take(10).toList();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (val) {
            _filterStudents(val);
            setState(() => _isDropdownOpen = true);
            if (val.isEmpty && widget.selectedStudent != null) {
              widget.onStudentSelected(null);
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _controller.clear();
                      widget.onStudentSelected(null);
                      setState(() {
                        _filterStudents('');
                        _isDropdownOpen = false;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
        ),
        if (_isDropdownOpen && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const Duration(milliseconds: 200) == Duration.zero ? null : const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (ctx, idx) {
                final s = _filtered[idx];
                return InkWell(
                  onTap: () {
                    widget.onStudentSelected(s);
                    _controller.text = s.compoundIdentity;
                    setState(() => _isDropdownOpen = false);
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '#${s.adm}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Class: ${s.studentClass}${s.father.isNotEmpty ? ' • S/o ${s.father}' : ''}${s.mobile.isNotEmpty ? ' • Ph: ${s.mobile}' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

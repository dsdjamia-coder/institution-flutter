import 'package:flutter/material.dart';
import '../../models/staff.dart';

class TeacherCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback? onTap;

  const TeacherCard({
    super.key,
    required this.staff,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _showTeacherDetails(context, staff),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 155,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Avatar with border
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: staff.photoUrl.isNotEmpty ? NetworkImage(staff.photoUrl) : null,
                child: staff.photoUrl.isEmpty
                    ? Text(
                        staff.name.isNotEmpty ? staff.name.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            // Teacher Name
            Text(
              staff.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            // Designation
            Text(
              (staff.designation.isNotEmpty ? staff.designation : staff.role).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showTeacherDetails(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: staff.photoUrl.isNotEmpty ? NetworkImage(staff.photoUrl) : null,
                child: staff.photoUrl.isEmpty
                    ? Text(
                        staff.name.isNotEmpty ? staff.name.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                staff.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                staff.designation.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              if (staff.place.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text('Place: ${staff.place}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              if (staff.phone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Text('Phone: ${staff.phone}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (staff.whatsapp.isNotEmpty || staff.phone.isNotEmpty)
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF25D366),
                  child: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                    tooltip: 'Chat on WhatsApp',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Contact: ${staff.whatsapp.isNotEmpty ? staff.whatsapp : staff.phone}')),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

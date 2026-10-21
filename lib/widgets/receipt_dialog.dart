import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/institution_setting.dart';

class ReceiptDialog extends StatelessWidget {
  final Payment payment;
  final InstitutionSetting setting;

  const ReceiptDialog({
    super.key,
    required this.payment,
    required this.setting,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FEE RECEIPT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Thermal Slip Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    setting.institutionName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (setting.place.isNotEmpty)
                    Text(
                      setting.place,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Receipt #: ${payment.receiptNo}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(payment.paymentDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Student: ${payment.studentName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Adm: ${payment.admissionNo}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Class: ${payment.studentClass}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const Divider(thickness: 1, height: 16),
                  // Paid Items
                  ...payment.feeItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.itemLabel} (${item.period})',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Text(
                            '${setting.currencySymbol}${item.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1.5, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAID:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(
                        '${setting.currencySymbol}${payment.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mode: ${payment.paymentMode} • Collector: ${payment.collectedByName}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt sent to print spooler!')),
                );
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

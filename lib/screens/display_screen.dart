import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/carbon_controller.dart';
import '../models/app_user.dart';
import '../models/carbon_record.dart';
import '../utils/format.dart';
import 'edit_screen.dart';

class DisplayScreen extends StatelessWidget {
  final AppUser user;
  final CarbonController _ctrl = CarbonController();

  DisplayScreen({super.key, required this.user});

  Future<void> _confirmDelete(BuildContext context, CarbonRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบรายการ ${r.costCenterId} ใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ลบ')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _ctrl.delete(r.id, user);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ลบข้อมูลสำเร็จ')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ctrl.snapshots, // collection().snapshots() แบบ Real-time
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snap.data!.docs.map(CarbonRecord.fromDoc).toList();
        if (records.isEmpty) {
          return const Center(child: Text('ยังไม่มีข้อมูล — ไปที่แท็บ "บันทึกข้อมูล"'));
        }
        final totalCo2 = records.fold<double>(0, (s, r) => s + r.tco2e);
        final totalBudget = records.fold<double>(0, (s, r) => s + r.offsetBudget);

        return Column(
          children: [
            // การ์ดสรุปยอดรวม (ส่วนเสริม: รวมค่าจากรายการทั้งหมด)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('รวมการปล่อย', '${formatNumber(totalCo2, decimals: 1)} tCO2e'),
                  _stat('งบชดเชยรวม', '฿${formatNumber(totalBudget)}'),
                  _stat('รายการ', '${records.length}'),
                ],
              ),
            ),
            if (!user.isAdmin)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('โหมด Operator: ดูข้อมูลและเพิ่มข้อมูลเท่านั้น',
                    style: TextStyle(color: Colors.grey)),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: records.length,
                itemBuilder: (context, i) {
                  final r = records[i];
                  return Card(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FittedBox(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(formatNumber(r.tco2e, decimals: 1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Text('tCO2e',
                                    style: TextStyle(fontSize: 8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      title: Text(r.costCenterId,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'แหล่งกำเนิด: ${r.emissionSource}\nงบชดเชย: ฿${formatNumber(r.offsetBudget)}'),
                      isThreeLine: true,
                      // Operator: ซ่อนปุ่ม Edit/Delete ทั้งหมด
                      trailing: user.isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditScreen(user: user, record: r),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(context, r),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

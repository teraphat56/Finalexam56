import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/carbon_record.dart';

class CarbonController {
  final _col = FirebaseFirestore.instance.collection('carbon_records');

  /// Real-time stream สำหรับ StreamBuilder
  Stream<QuerySnapshot<Map<String, dynamic>>> get snapshots =>
      _col.orderBy('createdAt', descending: true).snapshots();

  /// Create: ทั้ง Admin และ Operator ทำได้
  Future<void> add(CarbonRecord r, AppUser user) async {
    await _col.add({
      ...r.toMap(),
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update: เฉพาะ Admin (เช็คซ้ำที่ชั้น Controller อีกชั้น)
  Future<void> update(String id, CarbonRecord r, AppUser user) async {
    if (!user.isAdmin) throw Exception('Operator ไม่มีสิทธิ์แก้ไขข้อมูล');
    await _col.doc(id).update({
      ...r.toMap(),
      'updatedBy': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete: เฉพาะ Admin
  Future<void> delete(String id, AppUser user) async {
    if (!user.isAdmin) throw Exception('Operator ไม่มีสิทธิ์ลบข้อมูล');
    await _col.doc(id).delete();
  }
}

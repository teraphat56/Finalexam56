import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const testPassword = '123456';

  /// ใช้กันไม่ให้ AuthGate เด้งไปหน้าหลักระหว่างสร้างบัญชีทดสอบ
  static final ValueNotifier<bool> seeding = ValueNotifier<bool>(false);

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  /// อ่านสิทธิ์ผู้ใช้แบบ Real-time จาก users/{uid}
  Stream<AppUser?> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots().map(
            (d) => d.exists ? AppUser.fromMap(d.data()!) : null,
          );

  /// สร้างบัญชีทดสอบ admin@test.com / operator@test.com (รหัสผ่าน 123456)
  /// พร้อมบันทึก role ลง Firestore (กดครั้งเดียวก็พอ)
  Future<void> seedTestAccounts() async {
    seeding.value = true;
    try {
      final accounts = [
        {'name': 'Admin Test', 'email': 'admin@test.com', 'role': 'admin'},
        {'name': 'Operator Test', 'email': 'operator@test.com', 'role': 'operator'},
      ];
      for (final a in accounts) {
        UserCredential cred;
        try {
          cred = await _auth.createUserWithEmailAndPassword(
              email: a['email']!, password: testPassword);
        } on FirebaseAuthException catch (e) {
          if (e.code != 'email-already-in-use') rethrow;
          cred = await _auth.signInWithEmailAndPassword(
              email: a['email']!, password: testPassword);
        }
        final user = AppUser(
          uid: cred.user!.uid,
          name: a['name']!,
          email: a['email']!,
          role: a['role']!,
        );
        await _db.collection('users').doc(user.uid).set(user.toMap());
        await _auth.signOut();
      }
    } finally {
      seeding.value = false;
    }
  }
}

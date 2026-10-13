import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/app_user.dart';
import 'display_screen.dart';
import 'record_form.dart';

class HomeScreen extends StatelessWidget {
  final User firebaseUser;
  const HomeScreen({super.key, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    return StreamBuilder<AppUser?>(
      stream: auth.userStream(firebaseUser.uid),
      builder: (context, snap) {
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('EcoCarbon')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ไม่พบข้อมูลสิทธิ์ผู้ใช้ในคอลเลกชัน users'),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: auth.signOut, child: const Text('Sign Out')),
                ],
              ),
            ),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('EcoCarbon',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                Chip(
                  avatar: Icon(user.isAdmin ? Icons.shield : Icons.person,
                      size: 18),
                  label: Text(user.isAdmin ? 'Admin' : 'Operator'),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout),
                  onPressed: auth.signOut,
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.edit_note), text: 'บันทึกข้อมูล'),
                  Tab(icon: Icon(Icons.list_alt), text: 'รายการข้อมูล'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                RecordForm(user: user),
                DisplayScreen(user: user),
              ],
            ),
          ),
        );
      },
    );
  }
}

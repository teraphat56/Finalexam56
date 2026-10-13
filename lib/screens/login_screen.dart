import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(_email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      _msg('เข้าสู่ระบบไม่สำเร็จ: ${e.code}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      await _auth.seedTestAccounts();
      _msg('สร้างบัญชีทดสอบแล้ว (รหัสผ่าน ${AuthController.testPassword})');
    } on FirebaseAuthException catch (e) {
      _msg('สร้างบัญชีไม่สำเร็จ: ${e.code}');
    } catch (e) {
      _msg('สร้างบัญชีไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(String email) {
    _email.text = email;
    _password.text = AuthController.testPassword;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary, const Color(0xFFF4F8F5)],
            stops: const [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.eco, size: 72, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text('EcoCarbon',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Text('ESG Carbon Credit Tracker',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'อีเมล',
                                  prefixIcon: Icon(Icons.email_outlined)),
                              validator: MultiValidator([
                                RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                                EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                              ]).call,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                                MinLengthValidator(6,
                                    errorText: 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'),
                              ]).call,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: _loading ? null : _login,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.login),
                                label: const Text('เข้าสู่ระบบ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.admin_panel_settings, size: 18),
                        label: const Text('ใช้ Admin'),
                        onPressed: () => _fill('admin@test.com'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.person, size: 18),
                        label: const Text('ใช้ Operator'),
                        onPressed: () => _fill('operator@test.com'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _loading ? null : _seed,
                    child: const Text('สร้างบัญชีทดสอบ (ทำครั้งแรกครั้งเดียว)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

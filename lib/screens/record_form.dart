import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/carbon_controller.dart';
import '../models/app_user.dart';
import '../models/carbon_record.dart';

/// ฟอร์มบันทึก/แก้ไขข้อมูลการปล่อยคาร์บอน
/// - record == null  -> โหมดเพิ่มข้อมูล (แท็บที่ 1)
/// - record != null  -> โหมดแก้ไข (เปิดจากปุ่ม Edit เฉพาะ Admin)
class RecordForm extends StatefulWidget {
  final AppUser user;
  final CarbonRecord? record;
  final VoidCallback? onSaved;

  const RecordForm({super.key, required this.user, this.record, this.onSaved});

  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = CarbonController();

  late final TextEditingController _costCenter;
  late final TextEditingController _source;
  late final TextEditingController _email;
  late final TextEditingController _tco2e;
  late final TextEditingController _budget;
  bool _saving = false;

  bool get _isEdit => widget.record != null;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _costCenter = TextEditingController(text: r?.costCenterId ?? '');
    _source = TextEditingController(text: r?.emissionSource ?? '');
    _email = TextEditingController(text: r?.auditorEmail ?? '');
    _tco2e = TextEditingController(text: r == null ? '' : r.tco2e.toString());
    _budget =
        TextEditingController(text: r == null ? '' : r.offsetBudget.toString());
  }

  @override
  void dispose() {
    _costCenter.dispose();
    _source.dispose();
    _email.dispose();
    _tco2e.dispose();
    _budget.dispose();
    super.dispose();
  }

  String? _numberValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอก$label';
    final n = double.tryParse(v.trim());
    if (n == null) return '$label ต้องเป็นตัวเลขเท่านั้น';
    if (n < 0) return '$label ต้องไม่ติดลบ';
    return null;
  }

  Future<void> _save() async {
    // ทุกการบันทึกต้องผ่าน Validate ก่อนเสมอ
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final rec = CarbonRecord(
        costCenterId: _costCenter.text.trim(),
        emissionSource: _source.text.trim(),
        auditorEmail: _email.text.trim(),
        tco2e: double.parse(_tco2e.text.trim()),
        offsetBudget: double.parse(_budget.text.trim()),
      );
      if (_isEdit) {
        await _ctrl.update(widget.record!.id, rec, widget.user);
      } else {
        await _ctrl.add(rec, widget.user);
        _formKey.currentState!.reset();
      }
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'แก้ไขข้อมูลสำเร็จ' : 'บันทึกข้อมูลสำเร็จ')));
      widget.onSaved?.call();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  final _decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEdit ? 'แก้ไขข้อมูลการปล่อยคาร์บอน' : 'บันทึกการปล่อยคาร์บอน',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costCenter,
              decoration: const InputDecoration(
                labelText: 'รหัสศูนย์ต้นทุน / แผนก (Cost Center ID)',
                hintText: 'เช่น CC-ENG-04',
                prefixIcon: Icon(Icons.apartment),
              ),
              validator:
                  RequiredValidator(errorText: 'กรุณากรอกรหัสศูนย์ต้นทุน / แผนก')
                      .call,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _source,
              decoration: const InputDecoration(
                labelText: 'แหล่งกำเนิดการปล่อย (Emission Source)',
                hintText: 'เช่น การใช้ไฟฟ้า, ยานพาหนะ, ขนส่ง',
                prefixIcon: Icon(Icons.factory),
              ),
              validator:
                  RequiredValidator(errorText: 'กรุณากรอกแหล่งกำเนิดการปล่อย').call,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'อีเมลเจ้าหน้าที่ตรวจสอบสิ่งแวดล้อม (Auditor Email)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: MultiValidator([
                RequiredValidator(errorText: 'กรุณากรอกอีเมลผู้ตรวจสอบ'),
                EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
              ]).call,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tco2e,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _decimalOnly,
              decoration: const InputDecoration(
                labelText: 'ปริมาณการปล่อย (tCO2e)',
                prefixIcon: Icon(Icons.cloud_outlined),
              ),
              validator: (v) => _numberValidator(v, 'ปริมาณการปล่อย (tCO2e)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              inputFormatters: _decimalOnly,
              decoration: const InputDecoration(
                labelText: 'งบประมาณชดเชยที่จัดสรร (THB)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) => _numberValidator(v, 'งบประมาณชดเชย'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isEdit ? 'บันทึกการแก้ไข' : 'บันทึกข้อมูล'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

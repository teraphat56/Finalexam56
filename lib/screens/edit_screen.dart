import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/carbon_record.dart';
import 'record_form.dart';

class EditScreen extends StatelessWidget {
  final AppUser user;
  final CarbonRecord record;
  const EditScreen({super.key, required this.user, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไข ${record.costCenterId}')),
      body: RecordForm(
        user: user,
        record: record,
        onSaved: () => Navigator.pop(context),
      ),
    );
  }
}

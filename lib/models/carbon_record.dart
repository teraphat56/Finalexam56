import 'package:cloud_firestore/cloud_firestore.dart';

/// รายการการปล่อยคาร์บอน (Collection: carbon_records)
class CarbonRecord {
  final String id;
  final String costCenterId;
  final String emissionSource;
  final String auditorEmail;
  final double tco2e;
  final double offsetBudget;

  const CarbonRecord({
    this.id = '',
    required this.costCenterId,
    required this.emissionSource,
    required this.auditorEmail,
    required this.tco2e,
    required this.offsetBudget,
  });

  factory CarbonRecord.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return CarbonRecord(
      id: d.id,
      costCenterId: (m['costCenterId'] ?? '') as String,
      emissionSource: (m['emissionSource'] ?? '') as String,
      auditorEmail: (m['auditorEmail'] ?? '') as String,
      tco2e: ((m['tco2e'] ?? 0) as num).toDouble(),
      offsetBudget: ((m['offsetBudget'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'costCenterId': costCenterId,
        'emissionSource': emissionSource,
        'auditorEmail': auditorEmail,
        'tco2e': tco2e,
        'offsetBudget': offsetBudget,
      };
}

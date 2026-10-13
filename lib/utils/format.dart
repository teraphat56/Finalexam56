/// ใส่ comma คั่นหลักพัน เช่น 1234567.5 -> 1,234,567.50
String formatNumber(double v, {int decimals = 2}) {
  final parts = v.toStringAsFixed(decimals).split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return decimals == 0 ? intPart : '$intPart.${parts[1]}';
}

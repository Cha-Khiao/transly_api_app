import 'package:intl/intl.dart';

DateTime toThaiTime(DateTime dateTime) {
  return dateTime.add(const Duration(hours: 7));
}

String formatThaiDateShort(DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat('dd/MM/yyyy', 'th').format(dateTime.toLocal());
}

String formatThaiTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat('HH:mm', 'th').format(dateTime.toLocal());
}

String formatThaiDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  return '${formatThaiDateShort(dateTime)} ${formatThaiTime(dateTime)}';
}

DateTime toLocalDateForPicker(DateTime utcDateTime) {
  return utcDateTime.toLocal();
}

DateTime toUtcFromPicker(DateTime localDateTime) {
  return localDateTime.toUtc();
}

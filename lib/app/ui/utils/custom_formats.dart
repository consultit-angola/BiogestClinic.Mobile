import 'package:intl/intl.dart';

// ────────────────────────────────
// Date utilities
// ────────────────────────────────
String formatDayLabel(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date).inDays;

  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return DateFormat('dd/MM/yyyy').format(date);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatDate(dynamic date) {
  DateTime parsedDate;

  if (date is String) {
    parsedDate = DateTime.parse(date);
  } else if (date is DateTime) {
    parsedDate = date;
  } else {
    throw ArgumentError('The parameter must be DateTime or String.');
  }

  return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
}

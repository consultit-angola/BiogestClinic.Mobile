import 'package:biogest_clinic_mobile/app/ui/utils/custom_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('date formatting', () {
    test('isSameDay ignores the time', () {
      expect(
        isSameDay(DateTime(2026, 8, 6, 8), DateTime(2026, 8, 6, 23, 59)),
        isTrue,
      );
      expect(isSameDay(DateTime(2026, 8, 6), DateTime(2026, 8, 7)), isFalse);
    });

    test('formatDate accepts DateTime and ISO strings', () {
      expect(formatDate(DateTime(2026, 8, 6, 14, 5)), '06/08/2026 14:05');
      expect(formatDate('2026-08-06T14:05:00'), '06/08/2026 14:05');
    });

    test('formatDate rejects unsupported values', () {
      expect(() => formatDate(42), throwsArgumentError);
    });

    test('formatDayLabel formats dates older than yesterday', () {
      expect(formatDayLabel(DateTime(2020, 1, 2)), '02/01/2020');
    });
  });
}

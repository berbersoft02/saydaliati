import 'package:flutter_test/flutter_test.dart';
import 'package:saydaliati/core/services/opening_hours_service.dart';

void main() {
  const service = OpeningHoursService();

  // Wednesday 2026-07-15 10:30 local
  final wedMorning = DateTime(2026, 7, 15, 10, 30);
  // Wednesday evening
  final wedEvening = DateTime(2026, 7, 15, 21, 0);
  // Sunday afternoon
  final sunAfternoon = DateTime(2026, 7, 19, 14, 0);

  group('OpeningHoursService', () {
    test('24/7 is always open', () {
      expect(
        service.evaluate('24/7', at: wedMorning),
        OpenEvaluation.alwaysOpen,
      );
    });

    test('empty / null is unknown', () {
      expect(service.evaluate(null, at: wedMorning), OpenEvaluation.unknown);
      expect(service.evaluate('', at: wedMorning), OpenEvaluation.unknown);
      expect(service.evaluate('  ', at: wedMorning), OpenEvaluation.unknown);
    });

    test('Mo-Fr range open during hours', () {
      expect(
        service.evaluate('Mo-Fr 08:00-20:00', at: wedMorning),
        OpenEvaluation.open,
      );
    });

    test('Mo-Fr range closed after hours', () {
      expect(
        service.evaluate('Mo-Fr 08:00-20:00', at: wedEvening),
        OpenEvaluation.closed,
      );
    });

    test('Mo-Fr closed on Sunday', () {
      expect(
        service.evaluate('Mo-Fr 08:00-20:00', at: sunAfternoon),
        OpenEvaluation.closed,
      );
    });

    test('split lunch hours', () {
      expect(
        service.evaluate('Mo-Fr 08:00-12:00,14:00-18:00', at: wedMorning),
        OpenEvaluation.open,
      );
      final lunch = DateTime(2026, 7, 15, 13, 0);
      expect(
        service.evaluate('Mo-Fr 08:00-12:00,14:00-18:00', at: lunch),
        OpenEvaluation.closed,
      );
    });

    test('Sunday off override', () {
      expect(
        service.evaluate('Mo-Sa 08:00-20:00; Su off', at: sunAfternoon),
        OpenEvaluation.closed,
      );
      expect(
        service.evaluate('Mo-Sa 08:00-20:00; Su off', at: wedMorning),
        OpenEvaluation.open,
      );
    });

    test('overnight hours', () {
      final late = DateTime(2026, 7, 15, 23, 30);
      final early = DateTime(2026, 7, 16, 1, 0);
      expect(
        service.evaluate('Mo-Su 22:00-02:00', at: late),
        OpenEvaluation.open,
      );
      expect(
        service.evaluate('Mo-Su 22:00-02:00', at: early),
        OpenEvaluation.open,
      );
    });

    test('isOpenNow helper', () {
      expect(service.isOpenNow('24/7', at: wedMorning), isTrue);
      expect(service.isOpenNow('Mo-Fr 08:00-20:00', at: wedEvening), isFalse);
    });

    // Regression tests for fixes made during the audit.

    test('last matching rule wins (Su off after Mo-Sa)', () {
      // The override must be CLOSED, even though Mo-Sa includes Sa.
      final saturday = DateTime(2026, 7, 18, 10, 0); // Saturday
      expect(
        service.evaluate('Mo-Sa 08:00-20:00; Su off', at: saturday),
        OpenEvaluation.open,
      );
      // On Sunday, only the override applies, so the result must come from it.
      expect(
        service.evaluate('Mo-Sa 08:00-20:00; Su off', at: sunAfternoon),
        OpenEvaluation.closed,
      );
    });

    test('last rule wins for an off override inside a weekday block', () {
      // We off should turn the whole rule CLOSED on Wednesday.
      expect(
        service.evaluate('Mo-Fr 08:00-20:00; We off', at: wedMorning),
        OpenEvaluation.closed,
      );
      // But Monday should still be open.
      final monday = DateTime(2026, 7, 13, 10, 0);
      expect(
        service.evaluate('Mo-Fr 08:00-20:00; We off', at: monday),
        OpenEvaluation.open,
      );
    });

    test('wrap-around day range Sa-Mo', () {
      final saturday = DateTime(2026, 7, 18, 10, 0);
      final sunday = DateTime(2026, 7, 19, 10, 0);
      final monday = DateTime(2026, 7, 13, 10, 0);
      final tuesday = DateTime(2026, 7, 14, 10, 0);
      final spec = 'Sa-Mo 09:00-18:00';
      expect(service.evaluate(spec, at: saturday), OpenEvaluation.open);
      expect(service.evaluate(spec, at: sunday), OpenEvaluation.open);
      expect(service.evaluate(spec, at: monday), OpenEvaluation.open);
      expect(service.evaluate(spec, at: tuesday), OpenEvaluation.closed);
    });

    test('time-only rule applies every day', () {
      final saturday = DateTime(2026, 7, 18, 10, 0);
      final tuesday = DateTime(2026, 7, 14, 10, 0);
      expect(
        service.evaluate('08:00-20:00', at: saturday),
        OpenEvaluation.open,
      );
      expect(
        service.evaluate('08:00-20:00', at: tuesday),
        OpenEvaluation.open,
      );
      final night = DateTime(2026, 7, 14, 22, 0);
      expect(
        service.evaluate('08:00-20:00', at: night),
        OpenEvaluation.closed,
      );
    });

    test('closed / off literals', () {
      expect(service.evaluate('off'), OpenEvaluation.closed);
      expect(service.evaluate('closed'), OpenEvaluation.closed);
    });

    test('garbage spec returns unknown, never lies', () {
      expect(
        service.evaluate('Mo-Fr sunrise-sunset', at: wedMorning),
        OpenEvaluation.unknown,
      );
    });
  });
}

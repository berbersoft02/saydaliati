/// Evaluates OpenStreetMap `opening_hours` strings for common cases.
///
/// Supported (majority of pharmacy tags in practice):
/// - `24/7`
/// - `Mo-Fr 08:00-20:00`
/// - `Mo-Fr 08:00-12:00,14:00-18:00`
/// - `Mo,We,Fr 09:00-17:00`
/// - `Mo-Sa 08:00-20:00; Su off` / `Su closed`
/// - Multiple rules separated by `;`
///
/// Unsupported advanced syntax (year ranges, PH calendars, sunrise, etc.)
/// returns [OpenEvaluation.unknown] so the UI never lies.
class OpeningHoursService {
  const OpeningHoursService();

  /// Evaluate [spec] at [at] (local time of the device).
  OpenEvaluation evaluate(String? spec, {DateTime? at}) {
    final now = at ?? DateTime.now();
    if (spec == null) return OpenEvaluation.unknown;
    final raw = spec.trim();
    if (raw.isEmpty) return OpenEvaluation.unknown;

    final normalized = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized == '24/7' || normalized == 'open 24/7') {
      return OpenEvaluation.alwaysOpen;
    }
    if (normalized == 'closed' || normalized == 'off') {
      return OpenEvaluation.closed;
    }

    // Split on ';' into independent rules. Last matching day rule wins
    // for "off" overrides (e.g. Mo-Sa ...; Su off).
    final rules = raw
        .split(';')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (rules.isEmpty) return OpenEvaluation.unknown;

    // OSM spec: "the last matching rule wins" (not OR). This is the correct
    // semantic for overrides like `Mo-Su 08:00-20:00; Su off` or
    // `Mo-Fr 09:00-17:00; PH off` (where PH = public holidays).
    var sawApplicableRule = false;
    var sawDayTokenForToday = false;
    var result = OpenEvaluation.unknown;

    for (final rule in rules) {
      final ruleHasDay = _ruleHasDayToken(rule);
      final eval = _evaluateRule(rule, now);
      if (eval == null) {
        // Unparseable. If it had a day token and that day is today,
        // record that we don't know for today (not "closed").
        if (ruleHasDay && _ruleAppliesToday(rule, now.weekday)) {
          sawDayTokenForToday = true;
        }
        continue;
      }
      if (!eval.appliesToday) continue;
      sawApplicableRule = true;
      result = eval.isOpen ? OpenEvaluation.open : OpenEvaluation.closed;
    }

    if (!sawApplicableRule) {
      if (sawDayTokenForToday) {
        // We saw "Mo-Fr sunrise-sunset" on a Wednesday — we know the day
        // was scheduled, but the times are nonsense. Don't lie: return unknown.
        return OpenEvaluation.unknown;
      }
      // No applicable rule and no day-specific garbage for today.
      // If we saw any day token, the day is closed by default
      // (e.g. `Mo-Fr` on a Saturday → closed).
      // If we saw no day token at all (e.g. `08:00-20:00` only),
      // there's nothing to default to → unknown.
      final anyDayToken = rules.any(_ruleHasDayToken);
      return anyDayToken ? OpenEvaluation.closed : OpenEvaluation.unknown;
    }
    return result;
  }

  /// Convenience: true only when confidently open (incl. 24/7).
  bool isOpenNow(String? spec, {DateTime? at}) {
    final e = evaluate(spec, at: at);
    return e == OpenEvaluation.open || e == OpenEvaluation.alwaysOpen;
  }

  _RuleResult? _evaluateRule(String rule, DateTime now) {
    var r = rule.trim();
    if (r.isEmpty) return null;

    // "24/7" as a sub-rule
    if (r.toLowerCase() == '24/7') {
      return const _RuleResult(appliesToday: true, isOpen: true);
    }

    // Day part + optional time part
    // Examples: "Mo-Fr 08:00-20:00", "Su off", "Sa 09:00-13:00"
    final lower = r.toLowerCase();

    // Extract days token(s) at the start.
    final dayMatch = RegExp(
      r'^((?:(?:mo|tu|we|th|fr|sa|su)(?:-(?:mo|tu|we|th|fr|sa|su))?(?:,\s*)?)+|ph|weekdays|weekends)\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(r);

    if (dayMatch == null) {
      // Time-only rule like "08:00-20:00" → every day
      final times = _parseTimeRanges(r);
      if (times == null) return null;
      return _RuleResult(
        appliesToday: true,
        isOpen: _isNowInRanges(now, times),
      );
    }

    final dayPart = dayMatch.group(1)!.trim();
    final rest = dayMatch.group(2)!.trim();
    final applies = _dayApplies(dayPart, now.weekday);
    if (!applies) {
      return const _RuleResult(appliesToday: false, isOpen: false);
    }

    final restLower = rest.toLowerCase();
    if (rest.isEmpty) {
      // Day listed with no times — treat as unknown for that day
      return null;
    }
    if (restLower == 'off' || restLower == 'closed') {
      // "Su off" / "Su closed"
      return const _RuleResult(appliesToday: true, isOpen: false);
    }

    final times = _parseTimeRanges(rest);
    if (times == null) return null;
    return _RuleResult(
      appliesToday: true,
      isOpen: _isNowInRanges(now, times),
    );
  }

  bool _dayApplies(String dayPart, int weekday) {
    // weekday: DateTime.monday=1 ... sunday=7
    final token = dayPart.toLowerCase().replaceAll(' ', '');
    if (token == 'ph') return false; // public holidays: ignore (no calendar)
    if (token == 'weekdays') {
      return weekday >= DateTime.monday && weekday <= DateTime.friday;
    }
    if (token == 'weekends') {
      return weekday == DateTime.saturday || weekday == DateTime.sunday;
    }

    final days = <int>{};
    for (final piece in token.split(',')) {
      if (piece.isEmpty) continue;
      if (piece.contains('-')) {
        final parts = piece.split('-');
        if (parts.length != 2) continue;
        final a = _dayIndex(parts[0]);
        final b = _dayIndex(parts[1]);
        if (a == null || b == null) continue;
        var d = a;
        // Inclusive range, wrap not expected for Mo-Fr style
        while (true) {
          days.add(d);
          if (d == b) break;
          d = d == 7 ? 1 : d + 1;
          // safety
          if (days.length > 7) break;
        }
      } else {
        final d = _dayIndex(piece);
        if (d != null) days.add(d);
      }
    }
    return days.contains(weekday);
  }

  int? _dayIndex(String s) {
    switch (s.toLowerCase()) {
      case 'mo':
        return DateTime.monday;
      case 'tu':
        return DateTime.tuesday;
      case 'we':
        return DateTime.wednesday;
      case 'th':
        return DateTime.thursday;
      case 'fr':
        return DateTime.friday;
      case 'sa':
        return DateTime.saturday;
      case 'su':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  /// Parse "08:00-12:00,14:00-18:00" or "08:00-20:00".
  List<_TimeRange>? _parseTimeRanges(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return null;
    final ranges = <_TimeRange>[];
    for (final part in cleaned.split(',')) {
      final p = part.trim();
      if (p.isEmpty) continue;
      final m = RegExp(
        r'^(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})$',
      ).firstMatch(p);
      if (m == null) return null;
      final start = int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
      var end = int.parse(m.group(3)!) * 60 + int.parse(m.group(4)!);
      // Overnight e.g. 22:00-02:00
      ranges.add(_TimeRange(start, end));
    }
    return ranges.isEmpty ? null : ranges;
  }

  bool _isNowInRanges(DateTime now, List<_TimeRange> ranges) {
    final minutes = now.hour * 60 + now.minute;
    for (final r in ranges) {
      if (r.end < r.start) {
        // overnight
        if (minutes >= r.start || minutes < r.end) return true;
      } else {
        if (minutes >= r.start && minutes < r.end) return true;
      }
    }
    return false;
  }

  /// True if [rule] starts with a day-of-week token (or ph/weekdays/weekends),
  /// as opposed to a bare time range like "08:00-20:00".
  bool _ruleHasDayToken(String rule) {
    return RegExp(
      r'^\s*(?:(?:mo|tu|we|th|fr|sa|su)(?:-(?:mo|tu|we|th|fr|sa|su))?(?:,\s*)?)+|ph|weekdays|weekends',
      caseSensitive: false,
    ).hasMatch(rule);
  }

  /// True if [rule]'s leading day token covers [weekday]. Used so we can
  /// distinguish "rule didn't apply" from "rule applied but times are garbage".
  bool _ruleAppliesToday(String rule, int weekday) {
    final dayMatch = RegExp(
      r'^\s*((?:(?:mo|tu|we|th|fr|sa|su)(?:-(?:mo|tu|we|th|fr|sa|su))?(?:,\s*)?)+|ph|weekdays|weekends)',
      caseSensitive: false,
    ).firstMatch(rule);
    if (dayMatch == null) return false;
    return _dayApplies(dayMatch.group(1)!.trim(), weekday);
  }
}

enum OpenEvaluation {
  open,
  closed,
  alwaysOpen,
  unknown,
}

class _RuleResult {
  final bool appliesToday;
  final bool isOpen;
  const _RuleResult({required this.appliesToday, required this.isOpen});
}

class _TimeRange {
  final int start; // minutes from midnight
  final int end;
  const _TimeRange(this.start, this.end);
}

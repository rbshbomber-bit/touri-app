import 'package:shared_preferences/shared_preferences.dart';

/// 주간 AI 생성 카운터. 매주 월요일 0시에 자동 리셋.
class QuotaService {
  static const _kCount = 'weekly_ai_count';
  static const _kWeekStart = 'weekly_ai_week_start';
  static const int weeklyLimit = 3;

  DateTime _weekStart(DateTime now) {
    final mondayDate = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(mondayDate.year, mondayDate.month, mondayDate.day);
  }

  Future<int> _ensureFreshWeek(SharedPreferences prefs) async {
    final currentStart = _weekStart(DateTime.now());
    final stored = prefs.getString(_kWeekStart);
    if (stored != currentStart.toIso8601String()) {
      await prefs.setString(_kWeekStart, currentStart.toIso8601String());
      await prefs.setInt(_kCount, 0);
      return 0;
    }
    return prefs.getInt(_kCount) ?? 0;
  }

  Future<int> getCount() async {
    final prefs = await SharedPreferences.getInstance();
    return _ensureFreshWeek(prefs);
  }

  Future<int> getRemaining() async {
    final c = await getCount();
    final r = weeklyLimit - c;
    return r < 0 ? 0 : r;
  }

  Future<bool> canGenerate() async => (await getCount()) < weeklyLimit;

  Future<int> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final cur = await _ensureFreshWeek(prefs);
    final next = cur + 1;
    await prefs.setInt(_kCount, next);
    return next;
  }
}

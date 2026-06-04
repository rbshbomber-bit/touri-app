import 'package:shared_preferences/shared_preferences.dart';
import 'claude_service.dart';

/// 오늘의 affirmation 캐시 + 일일 카운터 (3회/일).
/// 자정 넘으면 카운터·캐시 리셋.
class AffirmationCacheService {
  static const _kText = 'affirmation_text_today';
  static const _kDate = 'affirmation_date';
  static const _kCount = 'affirmation_count_today';
  static const int dailyLimit = 3;

  final ClaudeService _claude = ClaudeService();

  String _today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<void> _ensureFreshDay(SharedPreferences prefs) async {
    final today = _today();
    if (prefs.getString(_kDate) != today) {
      await prefs.setString(_kDate, today);
      await prefs.setInt(_kCount, 0);
      await prefs.remove(_kText);
    }
  }

  Future<int> getCount() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureFreshDay(prefs);
    return prefs.getInt(_kCount) ?? 0;
  }

  Future<int> getRemaining() async {
    final c = await getCount();
    final r = dailyLimit - c;
    return r < 0 ? 0 : r;
  }

  Future<bool> canRefresh() async => (await getCount()) < dailyLimit;

  /// 캐시된 오늘의 affirmation을 반환. 없으면 null.
  Future<String?> getCached() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureFreshDay(prefs);
    return prefs.getString(_kText);
  }

  /// 초기 자동 로드용: 캐시 있으면 그것, 없으면 새로 받아서 캐시 (카운터 차감 X — 첫 무료).
  Future<String> initialOrFetch() async {
    final cached = await getCached();
    if (cached != null && cached.isNotEmpty) return cached;
    final text = await _claude.generateAffirmation();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kText, text);
    // 첫 자동 호출은 카운터 차감 안 함.
    return text;
  }

  /// 새로고침: 한도 차감 + 새 호출 + 캐시 갱신.
  /// 한도 초과면 null 반환.
  Future<String?> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureFreshDay(prefs);
    final cur = prefs.getInt(_kCount) ?? 0;
    if (cur >= dailyLimit) return null;
    final text = await _claude.generateAffirmation();
    await prefs.setInt(_kCount, cur + 1);
    await prefs.setString(_kText, text);
    return text;
  }
}

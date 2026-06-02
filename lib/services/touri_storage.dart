import 'package:shared_preferences/shared_preferences.dart';
import '../models/touri_entry.dart';
import '../models/touri_mood.dart';

/// shared_preferences로 날짜별 엔트리 저장.
/// 키 포맷: touri_entry_yyyy-MM-dd
class TouriStorage {
  static const _prefix = 'touri_entry_';

  static String dateKeyFor(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<TouriEntry> load(String dateKey, {TouriMood fallbackMood = TouriMood.secretary}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$dateKey');
    if (raw == null) {
      return TouriEntry(dateKey: dateKey, mood: fallbackMood);
    }
    try {
      return TouriEntry.decode(raw);
    } catch (_) {
      return TouriEntry(dateKey: dateKey, mood: fallbackMood);
    }
  }

  Future<void> save(TouriEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${entry.dateKey}', entry.encode());
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 오늘의 manifestation 체크리스트 5항목.
/// 매일 자정 자동 리셋.
class ChecklistService extends ChangeNotifier {
  ChecklistService._();
  static final instance = ChecklistService._();

  static const List<String> itemIds = [
    'breath',
    'gratitude',
    'manifest',
    'vision',
    'selfmessage',
  ];

  static const _kDate = 'checklist_date';
  static const _kPrefix = 'checklist_done_';
  static const _kSelfMessage = 'checklist_selfmessage_today';

  Map<String, bool> _cache = {for (final id in itemIds) id: false};
  String _selfMessage = '';
  bool _loaded = false;

  Map<String, bool> get items => Map.unmodifiable(_cache);
  String get selfMessage => _selfMessage;
  bool get allDone => _cache.values.every((v) => v);
  int get doneCount => _cache.values.where((v) => v).length;

  String _today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<void> _ensureFresh(SharedPreferences prefs) async {
    final today = _today();
    if (prefs.getString(_kDate) != today) {
      await prefs.setString(_kDate, today);
      for (final id in itemIds) {
        await prefs.setBool('$_kPrefix$id', false);
      }
      await prefs.remove(_kSelfMessage);
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureFresh(prefs);
    _cache = {
      for (final id in itemIds) id: prefs.getBool('$_kPrefix$id') ?? false,
    };
    _selfMessage = prefs.getString(_kSelfMessage) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDone(String id, bool done) async {
    if (!itemIds.contains(id)) return;
    final prefs = await SharedPreferences.getInstance();
    if (!_loaded) await load();
    _cache[id] = done;
    await prefs.setBool('$_kPrefix$id', done);
    notifyListeners();
  }

  Future<void> setSelfMessage(String text) async {
    final prefs = await SharedPreferences.getInstance();
    _selfMessage = text;
    await prefs.setString(_kSelfMessage, text);
    notifyListeners();
  }
}

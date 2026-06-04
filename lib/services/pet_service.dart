import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/touri_pet.dart';
import '../models/pet_stat.dart';
import '../models/growth_stage.dart';

/// 토우리 키우기 상태 관리.
/// 싱글톤 + ChangeNotifier — 홈 상태창, 돌보기 화면 등이 listen.
///
/// 사용:
///   await PetService.instance.init();
///   PetService.instance.reward(PetStat.heart, source: 'diary');  // 다이어리 저장
///   PetService.instance.feed();   // 돌보기 화면에서 밥주기
class PetService extends ChangeNotifier {
  PetService._();
  static final PetService instance = PetService._();

  static const _kKey = 'touri_pet_state_v1';

  TouriPet _pet = TouriPet.initial();
  TouriPet get pet => _pet;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// 마지막 reward로 인한 레벨업 정보 (UI에서 셀러브레이션용).
  GrowthStage? _justLeveledUp;
  GrowthStage? get justLeveledUp => _justLeveledUp;

  /// 오늘 이미 보상받은 행동 태그 (예: 'diary', 'manifest').
  /// 메모리 only — 앱 재시작 시 초기화 (가벼운 제약).
  final Set<String> _todayActions = {};
  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// 같은 행동에 하루 1회만 보상. 첫 호출이면 true 반환.
  bool rewardOncePerDay(PetStat stat, String tag, {int amount = 1}) {
    final key = '$tag:${_todayKey()}';
    if (_todayActions.contains(key)) return false;
    _todayActions.add(key);
    reward(stat, amount: amount, source: tag);
    return true;
  }

  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        _pet = TouriPet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _pet = TouriPet.initial();
      }
    }
    _checkDailyVisit();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_pet.toJson()));
  }

  /// 출석 체크. 어제 방문했으면 streak +1, 더 오래 빠지면 streak 1로 리셋.
  void _checkDailyVisit() {
    final now = DateTime.now();
    final last = _pet.lastVisit;
    final daysSince = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (daysSince == 0) {
      // 오늘 이미 방문
      return;
    }
    final newStreak = daysSince == 1 ? _pet.streak + 1 : 1;
    // 빠진 날에는 hunger/mood/energy 자연 감소 (안 들어와도 너무 패널티 X)
    final decay = daysSince.clamp(1, 3);
    _pet = _pet.copyWith(
      lastVisit: now,
      streak: newStreak,
      hunger: (_pet.hunger - decay).clamp(0, 10),
      mood: (_pet.mood - decay).clamp(0, 10),
      energy: (_pet.energy - decay).clamp(0, 10),
    );
    _save();
  }

  /// 능력치 보상. 행동 후 호출.
  /// source 는 SnackBar 메시지용 (예: 'diary', 'manifest', 'gratitude', 'news', 'spirituality', 'generate').
  void reward(PetStat stat, {int amount = 1, String source = ''}) {
    final newStats = Map<PetStat, int>.from(_pet.stats);
    newStats[stat] = ((newStats[stat] ?? 0) + amount).clamp(0, 99);
    final newXp = _pet.xp + amount;
    final prevStage = _pet.stage;
    _pet = _pet.copyWith(stats: newStats, xp: newXp);
    final nextStage = _pet.stage;
    if (nextStage != prevStage) {
      _justLeveledUp = nextStage;
    }
    _save();
    notifyListeners();
  }

  /// 레벨업 셀러브레이션 후 호출해서 플래그 클리어.
  void clearLevelUp() {
    _justLeveledUp = null;
    notifyListeners();
  }

  /// 돌보기 — 밥주기. 하루 1회 가능.
  bool feed() {
    if (!_pet.canCareToday) return false;
    _pet = _pet.copyWith(
      hunger: (_pet.hunger + 3).clamp(0, 10),
      lastCareAt: DateTime.now(),
    );
    reward(PetStat.love); // 밥 챙기는 행동 = 사랑
    return true;
  }

  /// 돌보기 — 놀아주기 (안기/말걸기). 하루 1회 가능.
  bool play() {
    if (!_pet.canCareToday) return false;
    _pet = _pet.copyWith(
      mood: (_pet.mood + 3).clamp(0, 10),
      lastCareAt: DateTime.now(),
    );
    reward(PetStat.heart);
    return true;
  }

  /// 돌보기 — 재우기. 하루 1회 가능.
  bool rest() {
    if (!_pet.canCareToday) return false;
    _pet = _pet.copyWith(
      energy: (_pet.energy + 3).clamp(0, 10),
      lastCareAt: DateTime.now(),
    );
    reward(PetStat.courage); // 휴식도 용기
    return true;
  }

  /// 마스터 단계에서 사용자가 칭호 부여.
  void setCustomTitle(String title) {
    _pet = _pet.copyWith(customTitle: title);
    _save();
    notifyListeners();
  }

  /// 디버그/리셋 (개발 중에만).
  Future<void> reset() async {
    _pet = TouriPet.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    _justLeveledUp = null;
    notifyListeners();
  }
}

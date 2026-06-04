import 'growth_stage.dart';
import 'pet_stat.dart';

/// 토우리 키우기 상태 스냅샷. shared_preferences에 JSON으로 저장.
class TouriPet {
  final int xp;
  final Map<PetStat, int> stats; // 각 능력치 0~99
  final int hunger; // 0~10 (0=배고픔, 10=배부름)
  final int mood;   // 0~10 (0=시무룩, 10=신남)
  final int energy; // 0~10 (0=피곤, 10=쌩쌩)
  final DateTime lastVisit;
  final int streak; // 연속 출석일
  final String? customTitle; // master 단계에서 사용자가 부여한 칭호
  final DateTime? lastCareAt; // 마지막 "돌보기" 시각 (일 1회 제한)

  TouriPet({
    required this.xp,
    required this.stats,
    required this.hunger,
    required this.mood,
    required this.energy,
    required this.lastVisit,
    required this.streak,
    this.customTitle,
    this.lastCareAt,
  });

  GrowthStage get stage => GrowthStage.fromXp(xp);

  /// 다음 단계까지 진행률 0~1.
  double get progressToNext {
    final next = stage.nextStage();
    if (next == null) return 1.0;
    final start = stage.xpThreshold;
    final end = next.xpThreshold;
    final span = end - start;
    if (span <= 0) return 1.0;
    return ((xp - start) / span).clamp(0.0, 1.0);
  }

  bool get canCareToday {
    if (lastCareAt == null) return true;
    final now = DateTime.now();
    final last = lastCareAt!;
    return now.year != last.year ||
        now.month != last.month ||
        now.day != last.day;
  }

  factory TouriPet.initial() => TouriPet(
        xp: 0,
        stats: {for (final s in PetStat.values) s: 0},
        hunger: 5,
        mood: 5,
        energy: 5,
        lastVisit: DateTime.now(),
        streak: 0,
      );

  TouriPet copyWith({
    int? xp,
    Map<PetStat, int>? stats,
    int? hunger,
    int? mood,
    int? energy,
    DateTime? lastVisit,
    int? streak,
    String? customTitle,
    DateTime? lastCareAt,
    bool clearCustomTitle = false,
  }) {
    return TouriPet(
      xp: xp ?? this.xp,
      stats: stats ?? this.stats,
      hunger: hunger ?? this.hunger,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      lastVisit: lastVisit ?? this.lastVisit,
      streak: streak ?? this.streak,
      customTitle: clearCustomTitle ? null : (customTitle ?? this.customTitle),
      lastCareAt: lastCareAt ?? this.lastCareAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'stats': {for (final e in stats.entries) e.key.name: e.value},
        'hunger': hunger,
        'mood': mood,
        'energy': energy,
        'lastVisit': lastVisit.toIso8601String(),
        'streak': streak,
        'customTitle': customTitle,
        'lastCareAt': lastCareAt?.toIso8601String(),
      };

  factory TouriPet.fromJson(Map<String, dynamic> json) {
    final rawStats = (json['stats'] as Map?) ?? {};
    final stats = <PetStat, int>{};
    for (final s in PetStat.values) {
      stats[s] = (rawStats[s.name] as int?) ?? 0;
    }
    return TouriPet(
      xp: json['xp'] as int? ?? 0,
      stats: stats,
      hunger: json['hunger'] as int? ?? 5,
      mood: json['mood'] as int? ?? 5,
      energy: json['energy'] as int? ?? 5,
      lastVisit: DateTime.tryParse(json['lastVisit'] as String? ?? '') ??
          DateTime.now(),
      streak: json['streak'] as int? ?? 0,
      customTitle: json['customTitle'] as String?,
      lastCareAt: json['lastCareAt'] == null
          ? null
          : DateTime.tryParse(json['lastCareAt'] as String),
    );
  }
}

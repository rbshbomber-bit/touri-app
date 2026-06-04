/// 토우리 성장 단계. 별가루 → 아기 → 친구 → 반짝 → 마스터.
/// 토우리는 별에서 온 존재. 별가루가 모여 토우리가 형성되고 자란다.
enum GrowthStage {
  stardust('별가루', '✨', 0),
  baby('아기 토우리', '🐣', 5),
  friend('친구 토우리', '🐰', 30),
  sparkle('반짝 토우리', '🌟', 100),
  master('마스터 토우리', '👑', 500);

  final String label;
  final String emoji;
  final int xpThreshold; // 이 단계 진입에 필요한 누적 XP
  const GrowthStage(this.label, this.emoji, this.xpThreshold);

  /// XP로 현재 단계 계산.
  static GrowthStage fromXp(int xp) {
    if (xp >= GrowthStage.master.xpThreshold) return GrowthStage.master;
    if (xp >= GrowthStage.sparkle.xpThreshold) return GrowthStage.sparkle;
    if (xp >= GrowthStage.friend.xpThreshold) return GrowthStage.friend;
    if (xp >= GrowthStage.baby.xpThreshold) return GrowthStage.baby;
    return GrowthStage.stardust;
  }

  /// 다음 단계까지 남은 XP. master면 null.
  int? xpToNext(int currentXp) {
    final next = nextStage();
    if (next == null) return null;
    return next.xpThreshold - currentXp;
  }

  GrowthStage? nextStage() {
    switch (this) {
      case GrowthStage.stardust:
        return GrowthStage.baby;
      case GrowthStage.baby:
        return GrowthStage.friend;
      case GrowthStage.friend:
        return GrowthStage.sparkle;
      case GrowthStage.sparkle:
        return GrowthStage.master;
      case GrowthStage.master:
        return null;
    }
  }

  /// 이 단계의 한 줄 설명 (UI에서 활용 가능).
  String get tagline {
    switch (this) {
      case GrowthStage.stardust:
        return '별에서 떨어진 작은 빛 — 너의 마음이 토우리를 부르고 있어';
      case GrowthStage.baby:
        return '별가루가 모여 갓 태어났어. 작고 둥글둥글한 아기 토우리';
      case GrowthStage.friend:
        return '함께 일기 쓰고 같이 자라는 친구 토우리';
      case GrowthStage.sparkle:
        return '오라가 빛나기 시작했어. 별을 부르는 힘이 강해진 토우리';
      case GrowthStage.master:
        return '왕관을 쓴 마스터 토우리. 너의 칭호를 부여해줘';
    }
  }

  /// 임시 이미지 경로 (Codex가 5장 생성 후 교체).
  String get imagePath {
    switch (this) {
      case GrowthStage.stardust:
        return 'assets/character/pet/stardust.png';
      case GrowthStage.baby:
        return 'assets/character/pet/baby.png';
      case GrowthStage.friend:
        return 'assets/character/pet/friend.png';
      case GrowthStage.sparkle:
        return 'assets/character/pet/sparkle.png';
      case GrowthStage.master:
        return 'assets/character/pet/master.png';
    }
  }

  /// fallback 이미지 (생성 이미지 없을 때).
  String get fallbackPath {
    switch (this) {
      case GrowthStage.stardust:
        return 'assets/character/news_categories/manifest.png';
      case GrowthStage.baby:
        return 'assets/character/menu_icons/collection.png';
      case GrowthStage.friend:
        return 'assets/character/scenes/scene_secretary_avatar.png';
      case GrowthStage.sparkle:
        return 'assets/character/menu_icons/spirituality.png';
      case GrowthStage.master:
        return 'assets/character/generated/touri_self_love_20260603_173440.png';
    }
  }
}

/// 토우리 능력치 5종. 행동 → 능력치 매핑은 PetService.
enum PetStat {
  heart('마음', '💗'),
  focus('집중', '🎯'),
  love('사랑', '💞'),
  courage('용기', '🔥'),
  sparkle('반짝임', '⭐');

  final String label;
  final String emoji;
  const PetStat(this.label, this.emoji);
}

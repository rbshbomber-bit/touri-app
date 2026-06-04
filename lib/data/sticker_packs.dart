/// 시즌 한정 스티커팩 카탈로그. 4 시즌 × 12장 = 48장.
class SeasonalPack {
  final String id;
  final String label;
  final String tag;
  final String description;
  final String coverPath;
  final List<String> items;
  final int priceWon;

  const SeasonalPack({
    required this.id,
    required this.label,
    required this.tag,
    required this.description,
    required this.coverPath,
    required this.items,
    required this.priceWon,
  });
}

List<String> _pack(String season) =>
    List.generate(12, (i) => 'assets/character/packs/$season/${(i + 1).toString().padLeft(2, '0')}.png');

const _spring = 'spring';
const _summer = 'summer';
const _autumn = 'autumn';
const _valentine = 'valentine';

final seasonalPacks = <SeasonalPack>[
  SeasonalPack(
    id: _spring,
    label: '봄벚꽃 토우리',
    tag: 'SPRING',
    description: '벚꽃 흩날리는 봄날, 토우리 12장',
    coverPath: 'assets/character/packs/spring/01.png',
    items: _pack(_spring),
    priceWon: 4900,
  ),
  SeasonalPack(
    id: _summer,
    label: '여름바다 토우리',
    tag: 'SUMMER',
    description: '햇살·바다·아이스크림과 토우리 12장',
    coverPath: 'assets/character/packs/summer/01.png',
    items: _pack(_summer),
    priceWon: 4900,
  ),
  SeasonalPack(
    id: _autumn,
    label: '추석한복 토우리',
    tag: 'AUTUMN',
    description: '한복 입은 가을 토우리 12장',
    coverPath: 'assets/character/packs/autumn/01.png',
    items: _pack(_autumn),
    priceWon: 4900,
  ),
  SeasonalPack(
    id: _valentine,
    label: '발렌타인 토우리',
    tag: 'VALENTINE',
    description: '하트와 초콜릿, 사랑스러운 토우리 12장',
    coverPath: 'assets/character/packs/valentine/01.png',
    items: _pack(_valentine),
    priceWon: 4900,
  ),
];

/// 다이어리 종이에 붙인 스티커 한 장.
/// 좌표·스케일·회전은 다이어리 페이퍼의 logical pixel 기준.
class DiarySticker {
  final String id;
  final String sourcePath;
  final double dx;
  final double dy;
  final double scale;
  final double rotation;

  const DiarySticker({
    required this.id,
    required this.sourcePath,
    required this.dx,
    required this.dy,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  DiarySticker copyWith({
    double? dx,
    double? dy,
    double? scale,
    double? rotation,
  }) {
    return DiarySticker(
      id: id,
      sourcePath: sourcePath,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourcePath': sourcePath,
        'dx': dx,
        'dy': dy,
        'scale': scale,
        'rotation': rotation,
      };

  static DiarySticker fromJson(Map<String, dynamic> json) => DiarySticker(
        id: json['id'] as String,
        sourcePath: json['sourcePath'] as String,
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      );
}

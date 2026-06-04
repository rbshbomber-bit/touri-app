import 'dart:convert';
import 'touri_mood.dart';
import 'diary_sticker.dart';
import 'generation_status.dart';

/// 하루치 토우리 엔트리. 날짜(yyyy-MM-dd)로 식별.
/// 본문은 무드와 무관하게 날짜당 하나, 무드는 그날의 느낌만 표시.
class TouriEntry {
  final String dateKey;
  final TouriMood mood;
  final String body;
  final String manifestation;
  final List<String> gratitude;
  final List<DiarySticker> stickers;
  final GenerationStatus generationStatus;
  final String? generationRequestId;
  final String? generatedImagePath;

  const TouriEntry({
    required this.dateKey,
    required this.mood,
    this.body = '',
    this.manifestation = '',
    this.gratitude = const ['', '', ''],
    this.stickers = const [],
    this.generationStatus = GenerationStatus.idle,
    this.generationRequestId,
    this.generatedImagePath,
  });

  TouriEntry copyWith({
    TouriMood? mood,
    String? body,
    String? manifestation,
    List<String>? gratitude,
    List<DiarySticker>? stickers,
    GenerationStatus? generationStatus,
    String? generationRequestId,
    String? generatedImagePath,
    bool clearGenerationRequestId = false,
    bool clearGeneratedImagePath = false,
  }) {
    return TouriEntry(
      dateKey: dateKey,
      mood: mood ?? this.mood,
      body: body ?? this.body,
      manifestation: manifestation ?? this.manifestation,
      gratitude: gratitude ?? this.gratitude,
      stickers: stickers ?? this.stickers,
      generationStatus: generationStatus ?? this.generationStatus,
      generationRequestId: clearGenerationRequestId ? null : (generationRequestId ?? this.generationRequestId),
      generatedImagePath: clearGeneratedImagePath ? null : (generatedImagePath ?? this.generatedImagePath),
    );
  }

  int get gratitudeFilled => gratitude.where((g) => g.trim().isNotEmpty).length;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'moodId': mood.id,
        'body': body,
        'manifestation': manifestation,
        'gratitude': gratitude,
        'stickers': stickers.map((s) => s.toJson()).toList(),
        'generationStatus': generationStatus.name,
        'generationRequestId': generationRequestId,
        'generatedImagePath': generatedImagePath,
      };

  static TouriEntry fromJson(Map<String, dynamic> json) {
    final list = (json['gratitude'] as List?)?.cast<String>() ?? const ['', '', ''];
    final padded = [...list];
    while (padded.length < 3) {
      padded.add('');
    }
    final stickerList = (json['stickers'] as List?)
            ?.map((s) => DiarySticker.fromJson(s as Map<String, dynamic>))
            .toList() ??
        const <DiarySticker>[];
    return TouriEntry(
      dateKey: json['dateKey'] as String,
      mood: TouriMood.fromId(json['moodId'] as String? ?? 'secretary'),
      body: json['body'] as String? ?? '',
      manifestation: json['manifestation'] as String? ?? '',
      gratitude: padded.take(3).toList(),
      stickers: stickerList,
      generationStatus: GenerationStatus.fromString(json['generationStatus'] as String? ?? 'idle'),
      generationRequestId: json['generationRequestId'] as String?,
      generatedImagePath: json['generatedImagePath'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());
  static TouriEntry decode(String s) =>
      TouriEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

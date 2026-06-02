import 'dart:convert';
import 'touri_mood.dart';

/// 하루치 토우리 엔트리. 날짜(yyyy-MM-dd)로 식별.
/// 본문은 무드와 무관하게 날짜당 하나, 무드는 그날의 느낌만 표시.
class TouriEntry {
  final String dateKey;
  final TouriMood mood;
  final String body;
  final String manifestation;
  final List<String> gratitude;

  const TouriEntry({
    required this.dateKey,
    required this.mood,
    this.body = '',
    this.manifestation = '',
    this.gratitude = const ['', '', ''],
  });

  TouriEntry copyWith({
    TouriMood? mood,
    String? body,
    String? manifestation,
    List<String>? gratitude,
  }) {
    return TouriEntry(
      dateKey: dateKey,
      mood: mood ?? this.mood,
      body: body ?? this.body,
      manifestation: manifestation ?? this.manifestation,
      gratitude: gratitude ?? this.gratitude,
    );
  }

  int get gratitudeFilled => gratitude.where((g) => g.trim().isNotEmpty).length;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'moodId': mood.id,
        'body': body,
        'manifestation': manifestation,
        'gratitude': gratitude,
      };

  static TouriEntry fromJson(Map<String, dynamic> json) {
    final list = (json['gratitude'] as List?)?.cast<String>() ?? const ['', '', ''];
    final padded = [...list];
    while (padded.length < 3) {
      padded.add('');
    }
    return TouriEntry(
      dateKey: json['dateKey'] as String,
      mood: TouriMood.fromId(json['moodId'] as String? ?? 'secretary'),
      body: json['body'] as String? ?? '',
      manifestation: json['manifestation'] as String? ?? '',
      gratitude: padded.take(3).toList(),
    );
  }

  String encode() => jsonEncode(toJson());
  static TouriEntry decode(String s) =>
      TouriEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

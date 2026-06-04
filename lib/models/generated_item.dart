/// 토우리 수집함의 한 장. 생성된 일러스트 + 메타.
class GeneratedItem {
  final String id;
  final String localPath;
  final String prompt;
  final DateTime createdAt;
  final String sourceDateKey;
  final String moodId;

  const GeneratedItem({
    required this.id,
    required this.localPath,
    required this.prompt,
    required this.createdAt,
    required this.sourceDateKey,
    required this.moodId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'localPath': localPath,
        'prompt': prompt,
        'createdAt': createdAt.toIso8601String(),
        'sourceDateKey': sourceDateKey,
        'moodId': moodId,
      };

  static GeneratedItem fromJson(Map<String, dynamic> j) => GeneratedItem(
        id: j['id'] as String,
        localPath: j['localPath'] as String,
        prompt: j['prompt'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        sourceDateKey: j['sourceDateKey'] as String,
        moodId: j['moodId'] as String,
      );
}

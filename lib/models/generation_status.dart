/// 토우리 일러스트 생성의 라이프사이클 상태.
enum GenerationStatus {
  idle,         // 아무 것도 안 함
  extracting,   // Claude로 scene 키워드 뽑는 중
  queued,       // FAL 큐에 들어감, 시작 대기
  generating,   // fal.ai 모델 돌고 있음
  downloading,  // 결과 PNG 다운로드 중
  ready,        // 완료, generatedImagePath 채워짐
  failed;       // 실패 (어느 단계든)

  static GenerationStatus fromString(String s) =>
      GenerationStatus.values.firstWhere((e) => e.name == s, orElse: () => GenerationStatus.idle);

  bool get isBusy =>
      this == extracting || this == queued || this == generating || this == downloading;
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/generation_status.dart';
import '../models/touri_mood.dart';
import 'claude_service.dart';
import 'fal_generation_service.dart';

/// 토우리 일러스트 생성 큐 + 폴링.
/// Singleton (GenerationOrchestrator.instance).
/// status 변화는 ChangeNotifier로 UI에 알림.
class GenerationOrchestrator extends ChangeNotifier {
  GenerationOrchestrator._();
  static final instance = GenerationOrchestrator._();

  final _claude = ClaudeService();
  final _fal = FalGenerationService();

  GenerationStatus _status = GenerationStatus.idle;
  String? _requestId;
  String? _errorMessage;
  String? _lastScene;
  Timer? _pollTimer;
  int _pollAttempts = 0;

  static const _maxPollAttempts = 60; // 10초 × 60 = 10분 max

  GenerationStatus get status => _status;
  String? get requestId => _requestId;
  String? get errorMessage => _errorMessage;
  String? get lastScene => _lastScene;
  bool get isBusy => _status.isBusy;

  void _setStatus(GenerationStatus s, {String? error}) {
    _status = s;
    _errorMessage = error;
    notifyListeners();
  }

  /// 일기·무드로 새 생성 시작. onProgress는 각 상태 변화마다 호출.
  /// onReady(localPath)는 완료 시 1회 호출.
  /// 이미 busy면 무시.
  /// 일기·무드로 새 생성. [scene]을 주면 Claude 추출 단계 건너뜀(다시 그리기용).
  Future<void> generate({
    required String diary,
    required TouriMood mood,
    required String dateKey,
    String? scene,
    required void Function(GenerationStatus, {String? requestId}) onProgress,
    required void Function(String localPath) onReady,
    required void Function(String error) onFailed,
  }) async {
    if (isBusy) return;

    try {
      String s;
      if (scene != null && scene.trim().isNotEmpty) {
        s = scene;
      } else {
        _setStatus(GenerationStatus.extracting);
        onProgress(GenerationStatus.extracting);
        s = await _claude.extractScene(diary, mood);
      }
      _lastScene = s;

      _setStatus(GenerationStatus.queued);
      onProgress(GenerationStatus.queued);

      final reqId = await _fal.submit(s);
      _requestId = reqId;
      _setStatus(GenerationStatus.generating);
      onProgress(GenerationStatus.generating, requestId: reqId);

      _startPolling(dateKey, onProgress, onReady, onFailed);
    } catch (e) {
      _setStatus(GenerationStatus.failed, error: e.toString());
      onFailed(e.toString());
    }
  }

  /// 앱 재시작 후 미완료 요청 이어받기.
  void resume({
    required String requestId,
    required String dateKey,
    required GenerationStatus lastStatus,
    required void Function(GenerationStatus, {String? requestId}) onProgress,
    required void Function(String localPath) onReady,
    required void Function(String error) onFailed,
  }) {
    if (isBusy) return;
    _requestId = requestId;
    _setStatus(lastStatus.isBusy ? lastStatus : GenerationStatus.generating);
    _startPolling(dateKey, onProgress, onReady, onFailed);
  }

  void _startPolling(
    String dateKey,
    void Function(GenerationStatus, {String? requestId}) onProgress,
    void Function(String localPath) onReady,
    void Function(String error) onFailed,
  ) {
    _pollAttempts = 0;
    _pollTimer?.cancel();
    Future<void> tick(Timer? timer) async {
      _pollAttempts++;
      if (_pollAttempts > _maxPollAttempts) {
        timer?.cancel();
        _setStatus(GenerationStatus.failed, error: '시간이 너무 오래 걸려. 다시 시도해줘.');
        onFailed(_errorMessage!);
        return;
      }

      try {
        final s = await _fal.pollStatus(_requestId!);
        if (s == 'COMPLETED') {
          timer?.cancel();
          _setStatus(GenerationStatus.downloading);
          onProgress(GenerationStatus.downloading);
          final url = await _fal.fetchResultUrl(_requestId!);
          final localPath = await _fal.download(url, dateKey);
          _setStatus(GenerationStatus.ready);
          onProgress(GenerationStatus.ready);
          onReady(localPath);
          _requestId = null;
          _pollAttempts = 0;
        } else if (s == 'FAILED') {
          timer?.cancel();
          _setStatus(GenerationStatus.failed, error: 'fal.ai 생성 실패.');
          onFailed(_errorMessage!);
        }
        // IN_QUEUE / IN_PROGRESS는 그대로 대기
      } catch (e) {
        if (_pollAttempts >= 3) {
          timer?.cancel();
          _setStatus(GenerationStatus.failed, error: e.toString());
          onFailed(e.toString());
        }
      }
    }

    _pollTimer = Timer.periodic(const Duration(seconds: 10), tick);
    tick(_pollTimer);
  }

  void reset() {
    _pollTimer?.cancel();
    _requestId = null;
    _pollAttempts = 0;
    _setStatus(GenerationStatus.idle);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

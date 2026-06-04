import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generated_item.dart';

/// 토우리 수집함.
/// - 이미지는 Documents/touri/collection/{id}.png로 복사 (mobile)
/// - Web에선 path_provider 불가 → URL/임시 경로 그대로 인덱스에만 보관
/// - 인덱스는 prefs에 JSON 배열
class CollectionService extends ChangeNotifier {
  CollectionService._();
  static final instance = CollectionService._();

  static const _kIndex = 'collection_index_v1';
  static const _subdir = 'touri/collection';

  List<GeneratedItem>? _cache;

  Future<List<GeneratedItem>> all() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kIndex);
    if (raw == null) {
      _cache = [];
      return _cache!;
    }
    try {
      final list = jsonDecode(raw) as List;
      _cache = list
          .map((e) => GeneratedItem.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _cache!;
    } catch (_) {
      _cache = [];
      return _cache!;
    }
  }

  Future<GeneratedItem> add({
    required String sourcePath,
    required String prompt,
    required String sourceDateKey,
    required String moodId,
  }) async {
    final id = _newId();
    String storedPath = sourcePath;

    // mobile/desktop이면 collection 폴더로 복사. Web/URL이면 그대로 보관.
    if (!kIsWeb && !sourcePath.startsWith('http')) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final collDir = Directory('${dir.path}/$_subdir');
        if (!await collDir.exists()) {
          await collDir.create(recursive: true);
        }
        final dest = File('${collDir.path}/$id.png');
        final src = File(sourcePath);
        if (await src.exists()) {
          await src.copy(dest.path);
          storedPath = dest.path;
        }
      } catch (_) {
        // 복사 실패하면 원본 경로 그대로 사용.
      }
    }

    final item = GeneratedItem(
      id: id,
      localPath: storedPath,
      prompt: prompt,
      createdAt: DateTime.now(),
      sourceDateKey: sourceDateKey,
      moodId: moodId,
    );

    final cur = await all();
    _cache = [item, ...cur];
    await _persist();
    notifyListeners();
    return item;
  }

  Future<void> delete(String id) async {
    final cur = await all();
    final target = cur.where((e) => e.id == id).toList();
    _cache = cur.where((e) => e.id != id).toList();

    // 파일도 정리 (best-effort).
    for (final t in target) {
      if (!kIsWeb && !t.localPath.startsWith('http')) {
        try {
          final f = File(t.localPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_cache!.map((e) => e.toJson()).toList());
    await prefs.setString(_kIndex, encoded);
  }

  static String _newId() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    // 0xFFFFFFFF == 2^32 - 1. 1 << 32는 Web(JS)에서 0으로 오버플로돼서 Random이 throw.
    final rnd = math.Random().nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    return '${ts}_$rnd';
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 答题音效：答对/答错/完成各有提示音
/// 播放失败不影响答题（静默忽略）
class SoundFx {
  static final SoundFx _i = SoundFx._();
  factory SoundFx() => _i;
  SoundFx._();

  AudioPlayer? _p;
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<AudioPlayer> _player() async {
    _p ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    return _p!;
  }

  Future<void> _play(String file, {double volume = 0.6}) async {
    if (!_enabled) return;
    try {
      final p = await _player();
      await p.stop();
      await p.setVolume(volume);
      await p.play(AssetSource('sounds/$file'));
    } catch (e) {
      // 音效失败不影响使用
      if (kDebugMode) debugPrint('sound error: $e');
    }
  }

  /// 答对：上行三音
  Future<void> correct() => _play('correct.wav', volume: 0.55);

  /// 答错：下行两音
  Future<void> wrong() => _play('wrong.wav', volume: 0.5);

  /// 一轮完成：四音上行
  Future<void> finish() => _play('finish.wav', volume: 0.6);

  Future<void> dispose() async {
    await _p?.dispose();
    _p = null;
  }
}

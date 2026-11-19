import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/eng_9a.dart';
import '../data/eng_9b.dart';

/// 短语
class Phrase {
  final String id;
  final String cn;
  final String en;
  final String module;
  final bool star;
  final String ex;    // 英文例句
  final String exCn;  // 例句翻译
  const Phrase({
    required this.id,
    required this.cn,
    required this.en,
    required this.module,
    this.star = false,
    this.ex = '',
    this.exCn = '',
  });

  factory Phrase.fromJson(Map<String, dynamic> j) => Phrase(
        id: j['id'],
        cn: j['cn'],
        en: j['en'],
        module: j['module'] ?? '',
        star: j['star'] == true,
        ex: j['ex'] ?? '',
        exCn: j['exCn'] ?? '',
      );
}

/// 一个短语的学习状态
class PhraseState {
  final String id;
  /// 已完成的新学轮次：0=未学，1=过完第1轮，2=过完第2轮，3=新学完成
  final int round;
  /// 总复习是否已通过
  final bool mastered;

  const PhraseState({
    required this.id,
    this.round = 0,
    this.mastered = false,
  });

  PhraseState copyWith({int? round, bool? mastered}) => PhraseState(
        id: id,
        round: round ?? this.round,
        mastered: mastered ?? this.mastered,
      );
}

class EnglishProvider extends ChangeNotifier {
  static const _kStates = 'phrase_states_v1';
  static const _kDaily = 'phrase_daily_v1';

  List<Phrase> _all = [];
  Map<String, PhraseState> _states = {};
  int _newPerDay = 5;

  List<Phrase> get all => _all;
  int get newPerDay => _newPerDay;

  Future<void> init() async {
    _all = [
      ...engPhrases9A.map(Phrase.fromJson),
      ...engPhrases9B.map(Phrase.fromJson),
    ];
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kStates);
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _states = m.map((k, v) => MapEntry(
              k,
              PhraseState(
                id: k,
                round: (v['r'] ?? 0) as int,
                mastered: (v['m'] ?? false) as bool,
              ),
            ));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    final m = _states.map((k, v) => MapEntry(k, {'r': v.round, 'm': v.mastered}));
    await sp.setString(_kStates, jsonEncode(m));
  }

  PhraseState stateOf(String id) =>
      _states[id] ?? PhraseState(id: id);

  // ===== 统计 =====
  int get total => _all.length;
  int get learnedCount =>
      _all.where((p) => stateOf(p.id).round >= 3).length;
  bool get allLearned => learnedCount >= total;

  /// 待新学（还没过完三轮）
  List<Phrase> get pending =>
      _all.where((p) => stateOf(p.id).round < 3).toList();

  /// 今日新学进度（简化为本次会话计数）
  int todayNew = 0;

  /// 总复习池：已学完但未掌握的
  List<Phrase> get reviewPool =>
      _all.where((p) {
        final s = stateOf(p.id);
        return s.round >= 3 && !s.mastered;
      }).toList();

  List<Phrase> get masteredList =>
      _all.where((p) => stateOf(p.id).mastered).toList();

  // ===== 新学 =====
  /// 取下一批要学的短语
  List<Phrase> nextBatch() {
    final p = pending;
    if (p.isEmpty) return [];
    return p.take(_newPerDay).toList();
  }

  /// 完成一轮（1/2/3）后更新状态
  Future<void> advanceRound(List<Phrase> batch, int doneRound) async {
    for (final ph in batch) {
      final cur = stateOf(ph.id);
      if (cur.round < doneRound) {
        _states[ph.id] = cur.copyWith(round: doneRound);
      }
    }
    notifyListeners();
    await _persist();
  }

  // ===== 总复习 =====
  /// 总复习答对：标记掌握
  Future<void> markMastered(String id) async {
    final cur = stateOf(id);
    _states[id] = cur.copyWith(mastered: true);
    notifyListeners();
    await _persist();
  }

  /// 重置全部进度
  Future<void> resetAll() async {
    _states = {};
    todayNew = 0;
    notifyListeners();
    await _persist();
  }

  /// 生成干扰项：从全部短语里取 3 个不同的中文释义
  List<String> distractors(Phrase target, int seed) {
    final pool = _all.where((p) => p.cn != target.cn).toList();
    if (pool.isEmpty) return [];
    final out = <String>[];
    var k = 1;
    while (out.length < 3 && k < pool.length * 2) {
      final cand = pool[(seed + k * 7) % pool.length].cn;
      if (!out.contains(cand)) out.add(cand);
      k++;
    }
    return out;
  }

  /// 生成干扰项：英文
  List<String> distractorsEn(Phrase target, int seed) {
    final pool = _all.where((p) => p.en != target.en).toList();
    if (pool.isEmpty) return [];
    final out = <String>[];
    var k = 1;
    while (out.length < 3 && k < pool.length * 2) {
      final cand = pool[(seed + k * 5) % pool.length].en;
      if (!out.contains(cand)) out.add(cand);
      k++;
    }
    return out;
  }
}

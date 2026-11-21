import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/eng_7a.dart';
import '../data/eng_7b.dart';
import '../data/eng_8a.dart';
import '../data/eng_8b.dart';
import '../data/eng_9a.dart';
import '../data/eng_9b.dart';
import '../data/eng_9c.dart';
import '../data/eng_9d.dart';
import '../data/eng_9s.dart';

/// 短语
class Phrase {
  final String id;
  final String cn;
  final String en;
  final String module;
  final bool star;
  final String ex;
  final String exCn;
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

/// 一个短语的学习状态（全局共享，与词书无关）
class PhraseState {
  final String id;
  final int round; // 0未学 1/2/3 已完成轮次
  final bool mastered;
  /// 学完第 3 轮的时间戳（毫秒），用于滚动复习排序
  final int at;
  const PhraseState({
    required this.id,
    this.round = 0,
    this.mastered = false,
    this.at = 0,
  });
  PhraseState copyWith({int? round, bool? mastered, int? at}) => PhraseState(
        id: id,
        round: round ?? this.round,
        mastered: mastered ?? this.mastered,
        at: at ?? this.at,
      );
}

/// 词书
class PhraseBook {
  final String key;
  final String label;
  final String desc;
  final List<String> grades; // 包含的册别
  const PhraseBook(this.key, this.label, this.desc, this.grades);
}

const List<PhraseBook> phraseBooks = [
  PhraseBook('g7', '七年级', '七年级上下册', ['7A', '7B']),
  PhraseBook('g8', '八年级', '八年级上下册', ['8A', '8B']),
  PhraseBook('g9', '九年级', '新版重点短语 M1-M11', ['9']),
  PhraseBook('all', '初中汇总', '七至九年级全部', ['7A', '7B', '8A', '8B', '9']),
];

class EnglishProvider extends ChangeNotifier {
  static const _kStates = 'phrase_states_v2';
  static const _kBook = 'phrase_current_book';
  static const _kPerDay = 'phrase_per_day';
  static const _kDaily = 'phrase_daily_counts';
  static const _kSeconds = 'phrase_daily_seconds';

  /// 全量短语（带册别标记）
  final Map<String, List<Phrase>> _byGrade = {};
  Map<String, PhraseState> _states = {};
  Map<String, int> _daily = {};
  Map<String, int> _seconds = {};
  String _bookKey = 'g9';
  int _newPerDay = 5;

  int get newPerDay => _newPerDay;
  String get bookKey => _bookKey;

  PhraseBook get currentBook =>
      phraseBooks.firstWhere((b) => b.key == _bookKey,
          orElse: () => phraseBooks.last);

  Future<void> init() async {
    _byGrade['7A'] = engPhrases7A.map(Phrase.fromJson).toList();
    _byGrade['7B'] = engPhrases7B.map(Phrase.fromJson).toList();
    _byGrade['8A'] = engPhrases8A.map(Phrase.fromJson).toList();
    _byGrade['8B'] = engPhrases8B.map(Phrase.fromJson).toList();
    // 九年级：新版重点短语总结 M1-M11 + 旧版补充，合并去重
    final nine = <Phrase>[
      ...engPhrases9A.map(Phrase.fromJson),
      ...engPhrases9B.map(Phrase.fromJson),
      ...engPhrases9C.map(Phrase.fromJson),
      ...engPhrases9D.map(Phrase.fromJson),
      ...engPhrases9S.map(Phrase.fromJson),
    ];
    final seen = <String>{};
    _byGrade['9'] = nine.where((p) {
      final k = p.en.toLowerCase().trim();
      if (seen.contains(k)) return false;
      seen.add(k);
      return true;
    }).toList();

    final sp = await SharedPreferences.getInstance();
    _bookKey = sp.getString(_kBook) ?? 'g9';
    _newPerDay = sp.getInt(_kPerDay) ?? 10;
    final rawDaily = sp.getString(_kDaily);
    if (rawDaily != null && rawDaily.isNotEmpty) {
      try {
        final m = jsonDecode(rawDaily) as Map<String, dynamic>;
        _daily = m.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
    final rawSec = sp.getString(_kSeconds);
    if (rawSec != null && rawSec.isNotEmpty) {
      try {
        final m = jsonDecode(rawSec) as Map<String, dynamic>;
        _seconds = m.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
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
                at: (v['a'] ?? 0) as int,
              ),
            ));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    final m = _states
        .map((k, v) => MapEntry(k, {'r': v.round, 'm': v.mastered, 'a': v.at}));
    await sp.setString(_kStates, jsonEncode(m));
    await sp.setString(_kBook, _bookKey);
    await sp.setInt(_kPerDay, _newPerDay);
    await sp.setString(_kDaily, jsonEncode(_daily));
    await sp.setString(_kSeconds, jsonEncode(_seconds));
  }

  Future<void> setNewPerDay(int n) async {
    _newPerDay = n.clamp(1, 200);
    notifyListeners();
    await _persist();
  }

  Future<void> selectBook(String key) async {
    _bookKey = key;
    notifyListeners();
    await _persist();
  }

  PhraseState stateOf(String id) => _states[id] ?? PhraseState(id: id);

  /// 某本词书包含的全部短语（按册别顺序）
  List<Phrase> phrasesOf(String bookKey) {
    final book = phraseBooks.firstWhere((b) => b.key == bookKey,
        orElse: () => phraseBooks.last);
    final out = <Phrase>[];
    for (final g in book.grades) {
      out.addAll(_byGrade[g] ?? const []);
    }
    return out;
  }

  /// 当前词书的短语
  List<Phrase> get pool => phrasesOf(_bookKey);

  /// 全部短语（干扰项用）
  List<Phrase> get allPhrases {
    final out = <Phrase>[];
    for (final g in ['7A', '7B', '8A', '8B', '9']) {
      out.addAll(_byGrade[g] ?? const []);
    }
    return out;
  }

  // ===== 统计（基于当前词书） =====
  int get total => pool.length;
  int get learnedCount => pool.where((p) => stateOf(p.id).round >= 3).length;
  bool get allLearned => total > 0 && learnedCount >= total;

  List<Phrase> get pending =>
      pool.where((p) => stateOf(p.id).round < 3).toList();

  List<Phrase> get reviewPool => pool.where((p) {
        final s = stateOf(p.id);
        return s.round >= 3 && !s.mastered;
      }).toList();

  int get masteredCount =>
      pool.where((p) => stateOf(p.id).mastered).length;

  /// 某本词书的已学数（首页展示用）
  int learnedOf(String bookKey) {
    final list = phrasesOf(bookKey);
    return list.where((p) => stateOf(p.id).round >= 3).length;
  }

  int totalOf(String bookKey) => phrasesOf(bookKey).length;

  /// 剩余待学数量
  int get pendingCount => pending.length;

  /// 按每天 n 个，预计多少天学完
  int estimatedDays(int perDay) {
    if (perDay <= 0) return 0;
    return (pendingCount / perDay).ceil();
  }

  // ===== 新学 =====
  List<Phrase> nextBatch() {
    final p = pending;
    if (p.isEmpty) return [];
    return p.take(_newPerDay).toList();
  }

  Future<void> advanceRound(List<Phrase> batch, int doneRound) async {
    var newlyDone = 0;
    for (final ph in batch) {
      final cur = stateOf(ph.id);
      if (cur.round < doneRound) {
        final stamp = (doneRound >= 3 && cur.round < 3)
            ? DateTime.now().millisecondsSinceEpoch
            : cur.at;
        _states[ph.id] = cur.copyWith(round: doneRound, at: stamp);
        if (doneRound >= 3 && cur.round < 3) newlyDone++;
      }
    }
    // 记录今天真正学完（走完三轮）的数量
    if (newlyDone > 0) {
      final k = _ymd(DateTime.now());
      _daily[k] = (_daily[k] ?? 0) + newlyDone;
    }
    notifyListeners();
    await _persist();
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 最近学过的 n 个短语（用于滚动复习，最近的排前面）
  List<Phrase> recentLearned(int n) {
    final list = pool.where((p) => stateOf(p.id).round >= 3).toList()
      ..sort((a, b) => stateOf(b.id).at.compareTo(stateOf(a.id).at));
    return list.take(n).toList();
  }

  /// 已学完总数（当前词书）
  int get learnedInBook =>
      pool.where((p) => stateOf(p.id).round >= 3).length;

  /// 今日学完数量
  int get todayLearned => _daily[_ymd(DateTime.now())] ?? 0;

  /// 累计学完数量（跨词书）
  int get totalLearnedAll =>
      _daily.values.fold<int>(0, (a, b) => a + b);

  /// 记录一次学习会话的时长
  Future<void> addStudySeconds(int sec) async {
    if (sec <= 0 || sec > 7200) return; // 过滤异常值
    final k = _ymd(DateTime.now());
    _seconds[k] = (_seconds[k] ?? 0) + sec;
    notifyListeners();
    await _persist();
  }

  /// 今日学习时长（分钟）
  int get todayMinutes => ((_seconds[_ymd(DateTime.now())] ?? 0) / 60).round();

  /// 累计学习时长（分钟）
  int get totalMinutes =>
      (_seconds.values.fold<int>(0, (a, b) => a + b) / 60).round();

  /// 连续学习天数
  int get streak {
    var n = 0;
    var d = DateTime.now();
    if ((_daily[_ymd(d)] ?? 0) == 0) {
      d = d.subtract(const Duration(days: 1));
    }
    while ((_daily[_ymd(d)] ?? 0) > 0) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// 最近 n 天每天的学习量（从早到晚）
  List<MapEntry<DateTime, int>> recentDays(int n) {
    final out = <MapEntry<DateTime, int>>[];
    final now = DateTime.now();
    for (var i = n - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      out.add(MapEntry(d, _daily[_ymd(d)] ?? 0));
    }
    return out;
  }

  // ===== 总复习 =====
  Future<void> markMastered(String id) async {
    _states[id] = stateOf(id).copyWith(mastered: true);
    notifyListeners();
    await _persist();
  }

  Future<void> resetBook() async {
    for (final p in pool) {
      _states.remove(p.id);
    }
    notifyListeners();
    await _persist();
  }

  // ===== 干扰项 =====
  List<String> distractors(Phrase target, int seed) {
    final pool = allPhrases.where((p) => p.cn != target.cn).toList();
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

  List<String> distractorsEn(Phrase target, int seed) {
    final pool = allPhrases.where((p) => p.en != target.en).toList();
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

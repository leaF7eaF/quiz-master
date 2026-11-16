import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../data/all_questions.dart';

/// 刷题状态与本地持久化
class QuizProvider extends ChangeNotifier {
  static const _kRecords = 'answer_records_v1';

  List<Question> _all = [];
  List<AnswerRecord> _records = [];
  String _subject = 'politics';
  String? _filterUnit;
  String? _filterKnowledge;
  String? _filterWorkbook;

  List<Question> get all => _all;
  List<AnswerRecord> get records => _records;
  String get subject => _subject;
  String? get filterUnit => _filterUnit;
  String? get filterKnowledge => _filterKnowledge;
  String? get filterWorkbook => _filterWorkbook;

  Future<void> init() async {
    _all = buildAllQuestions();
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kRecords);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _records = list.map((m) => AnswerRecord(
              qid: m['qid'] as String,
              subject: m['subject'] as String,
              knowledge: (m['knowledge'] ?? '') as String,
              workbook: (m['workbook'] ?? '') as String,
              correct: m['correct'] as bool,
              timeMs: (m['timeMs'] ?? 0) as int,
              when: DateTime.fromMillisecondsSinceEpoch(m['when'] as int),
            )).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    final list = _records
        .map((r) => {
              'qid': r.qid,
              'subject': r.subject,
              'knowledge': r.knowledge,
              'workbook': r.workbook,
              'correct': r.correct,
              'timeMs': r.timeMs,
              'when': r.when.millisecondsSinceEpoch,
            })
        .toList();
    await sp.setString(_kRecords, jsonEncode(list));
  }

  // ===== 选择 / 筛选 =====
  void selectSubject(String s) {
    _subject = s;
    _filterUnit = null;
    _filterKnowledge = null;
    _filterWorkbook = null;
    notifyListeners();
  }

  void setFilterUnit(String? u) { _filterUnit = u; notifyListeners(); }
  void setFilterKnowledge(String? k) { _filterKnowledge = k; notifyListeners(); }
  void setFilterWorkbook(String? w) { _filterWorkbook = w; notifyListeners(); }

  /// 当前科目下的题目
  List<Question> get currentSubjectQuestions =>
      _all.where((q) => q.subject == _subject).toList();

  /// 经过所有筛选条件的题目
  List<Question> get filteredQuestions {
    var list = currentSubjectQuestions;
    if (_filterUnit != null) list = list.where((q) => q.unit == _filterUnit).toList();
    if (_filterKnowledge != null) list = list.where((q) => q.knowledge == _filterKnowledge).toList();
    if (_filterWorkbook != null) list = list.where((q) => q.workbook == _filterWorkbook).toList();
    return list;
  }

  /// 按中文序号提取数字排序：第一(1)、二(2)…十(10)、十一(11)…
  static final Map<String, int> _cnNum = {
    '零': 0, '一': 1, '二': 2, '三': 3, '四': 4, '五': 5,
    '六': 6, '七': 7, '八': 8, '九': 9, '十': 10,
  };

  static int cnNumValue(String s) {
    // 匹配"第十单元"“第11课”这类：优先阿拉伯数字
    final arabic = RegExp(r'(\d+)').firstMatch(s);
    if (arabic != null) return int.parse(arabic.group(1)!);
    final m = RegExp(r'第([零一二三四五六七八九十]+)').firstMatch(s);
    if (m == null) return 999; // 无序号的排最后
    final cn = m.group(1)!;
    // 简单支持"十""十一"…“二十"组合
    if (cn == '十') return 10;
    final tenIdx = cn.indexOf('十');
    if (tenIdx < 0) return _cnNum[cn] ?? 999;
    final tens = tenIdx == 0 ? 1 : (_cnNum[cn.substring(0, tenIdx)] ?? 1);
    final ones = tenIdx + 1 < cn.length ? (_cnNum[cn.substring(tenIdx + 1)] ?? 0) : 0;
    return tens * 10 + ones;
  }

  /// 单元列表，按序号排
  List<String> get units {
    final list = currentSubjectQuestions.map((q) => q.unit).toSet().toList();
    list.sort((a, b) => cnNumValue(a).compareTo(cnNumValue(b)));
    return list;
  }

  /// 某单元下的课列表（按教材顺序）
  List<String> lessonsOf(String unit) {
    final list = currentSubjectQuestions
        .where((q) => q.unit == unit)
        .map((q) => q.lesson)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();
    list.sort((a, b) => cnNumValue(a).compareTo(cnNumValue(b)));
    return list;
  }

  /// 某课下的题目
  List<Question> questionsOfLesson(String unit, String lesson) =>
      currentSubjectQuestions
          .where((q) => q.unit == unit && q.lesson == lesson)
          .toList();
  /// 知识点列表，按序号排
  List<String> get knowledges {
    final list = currentSubjectQuestions.map((q) => q.knowledge).toSet().toList();
    list.sort((a, b) => cnNumValue(a).compareTo(cnNumValue(b)));
    return list;
  }

  /// 来源列表，按序号排
  List<String> get workbooks {
    final list = currentSubjectQuestions.map((q) => q.workbook).toSet().toList();
    list.sort((a, b) => cnNumValue(a).compareTo(cnNumValue(b)));
    return list;
  }

  // ===== 答题 =====
  Future<void> answer(Question q, bool correct, int timeMs) async {
    _records.add(AnswerRecord(
      qid: q.id,
      subject: q.subject,
      knowledge: q.knowledge,
      workbook: q.workbook,
      correct: correct,
      timeMs: timeMs,
      when: DateTime.now(),
    ));
    notifyListeners();
    await _persist();
  }

  // ===== 统计 =====
  int get totalAnswered => _records.length;
  int get totalCorrect => _records.where((r) => r.correct).length;
  double get accuracy =>
      totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  /// 某天做题数（热力图用），key 为 yyyy-MM-dd
  Map<String, int> get dailyCounts {
    final m = <String, int>{};
    for (final r in _records) {
      final k = _ymd(r.when);
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  /// 连续打卡天数
  int get streak {
    final days = dailyCounts.keys.toSet();
    if (days.isEmpty) return 0;
    int count = 0;
    var d = DateTime.now();
    // 若今天没做，从昨天开始算
    if (!days.contains(_ymd(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    while (days.contains(_ymd(d))) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// 今日做题数
  int get todayCount => dailyCounts[_ymd(DateTime.now())] ?? 0;

  /// 按知识点正确率（当前科目）
  Map<String, double> get accuracyByKnowledge {
    final total = <String, int>{};
    final correct = <String, int>{};
    for (final r in _records) {
      if (r.subject != _subject) continue;
      final k = r.knowledge.isEmpty ? '未分类' : r.knowledge;
      total[k] = (total[k] ?? 0) + 1;
      if (r.correct) correct[k] = (correct[k] ?? 0) + 1;
    }
    return total.map((k, t) => MapEntry(k, (correct[k] ?? 0) / t));
  }

  /// 薄弱知识点（正确率<60%，且至少做过1题）
  List<MapEntry<String, double>> get weakKnowledges {
    final acc = accuracyByKnowledge;
    final list = acc.entries.where((e) => e.value < 0.6).toList();
    list.sort((a, b) => a.value.compareTo(b.value));
    return list;
  }

  /// 错题列表（当前科目，去重保留最近一次做错且之后没做对的）
  List<Question> get wrongQuestions {
    final lastResult = <String, bool>{};
    for (final r in _records) {
      if (r.subject != _subject) continue;
      lastResult[r.qid] = r.correct;
    }
    final ids = lastResult.entries.where((e) => !e.value).map((e) => e.key).toSet();
    return currentSubjectQuestions.where((q) => ids.contains(q.id)).toList();
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 重置全部记录
  Future<void> resetAll() async {
    _records.clear();
    notifyListeners();
    await _persist();
  }

  // ===== 存档导出 / 导入 =====

  /// 导出：一行一条，字段用制表符分隔，前 8 位是校验头
  String exportArchive() {
    final buf = StringBuffer();
    buf.writeln('QUIZMASTER_ARCHIVE_V1');
    buf.writeln('total=${_records.length}');
    for (final r in _records) {
      buf.writeln([
        r.qid,
        r.subject,
        r.knowledge,
        r.workbook,
        r.correct ? 1 : 0,
        r.timeMs,
        r.when.millisecondsSinceEpoch,
      ].join('\t'));
    }
    return buf.toString();
  }

  /// 导入：替换模式 or 合并模式（按 qid+时间戳去重）
  Future<String> importArchive(String text, {bool merge = true}) async {
    final lines = text.trim().split('\n');
    if (lines.isEmpty || lines.first.trim() != 'QUIZMASTER_ARCHIVE_V1') {
      return '存档格式不正确';
    }
    final parsed = <AnswerRecord>[];
    for (final line in lines.skip(1)) {
      if (line.startsWith('total=')) continue;
      if (line.trim().isEmpty) continue;
      final f = line.split('\t');
      if (f.length < 7) continue;
      try {
        parsed.add(AnswerRecord(
          qid: f[0],
          subject: f[1],
          knowledge: f[2],
          workbook: f[3],
          correct: f[4] == '1',
          timeMs: int.tryParse(f[5]) ?? 0,
          when: DateTime.fromMillisecondsSinceEpoch(int.tryParse(f[6]) ?? 0),
        ));
      } catch (_) {}
    }
    if (parsed.isEmpty) return '存档中没有有效记录';

    if (merge) {
      final seen = _records.map((r) => '${r.qid}|${r.when.millisecondsSinceEpoch}').toSet();
      var added = 0;
      for (final r in parsed) {
        final k = '${r.qid}|${r.when.millisecondsSinceEpoch}';
        if (seen.contains(k)) continue;
        seen.add(k);
        _records.add(r);
        added++;
      }
      notifyListeners();
      await _persist();
      return '合并完成：新增 $added 条（原有 ${_records.length - added} 条）';
    } else {
      _records
        ..clear()
        ..addAll(parsed);
      notifyListeners();
      await _persist();
      return '恢复完成：共 ${_records.length} 条记录';
    }
  }
}

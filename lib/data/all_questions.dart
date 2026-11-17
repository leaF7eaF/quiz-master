import '../models/question.dart';
import 'politics_2026_unit1.dart';
import 'politics_2026_unit234.dart';
import 'politics_essential_2026.dart';
import 'history_2026_unit14.dart';
import 'history_2026_unit57.dart';
import 'history_essential_unit14.dart';
import 'history_essential_unit57.dart';
import 'chinese_2026.dart';
import 'chinese_recite.dart';
import 'chemistry_2026.dart';
import 'glossary_yueyang.dart';
import 'glossary_zuiweng.dart';
import 'glossary_caoqui.dart';
import 'glossary_chenshe.dart';

/// 注释库来源（篇目 → 注释列表）
const Map<String, List<Map<String, dynamic>>> glossarySources = {
  '岳阳楼记': glossaryYueyang,
  '醉翁亭记': glossaryZuiweng,
  '湖心亭看雪': glossaryHuxin,
  '曹刿论战': glossaryCaoqui,
  '邹忌讽齐王纳谏': glossaryZouji,
  '陈涉世家': glossaryChenshe,
  '出师表': glossaryChushi,
};

/// 把注释库展开成题目：
/// 1) 速过卡（flash）：看词 → 想意思 → 翻面自评
/// 2) 注释测验（single）：问意思，四选一，干扰项从同篇其他注释取
List<Map<String, dynamic>> buildGlossaryQuestions() {
  final out = <Map<String, dynamic>>[];

  glossarySources.forEach((lesson, entries) {
    final n = entries.length;
    if (n == 0) return;

    // ---- 速过卡 ----
    for (var i = 0; i < n; i++) {
      final g = entries[i];
      final star = g['star'] == true;
      out.add({
        'id': 'gl_${_slug(lesson)}_f$i',
        'subject': 'chinese',
        'grade': '九年级',
        'unit': '文言文注释 · 速过',
        'lesson': lesson,
        'knowledge': star ? '重点注释' : '常规注释',
        'workbook': '自编',
        'type': 'flash',
        'stem': '「${g['word']}」的意思是？',
        'options': <String>[],
        'answer': g['meaning'],
        'analysis': '出自《$lesson》${star ? '（重点考点）' : ''}',
        'difficulty': star ? 3 : 1,
      });
    }

    // ---- 注释测验（选择题）----
    for (var i = 0; i < n; i++) {
      final g = entries[i];
      final correct = g['meaning'] as String;
      final star = g['star'] == true;

      // 确定性挑选 3 个干扰项（保证每次构建结果一致）
      final distractors = <String>[];
      var k = 1;
      while (distractors.length < 3 && k < n * 4) {
        final cand = entries[(i + k * 7 + 3) % n]['meaning'] as String;
        if (cand != correct && !distractors.contains(cand)) {
          distractors.add(cand);
        }
        k++;
      }
      while (distractors.length < 3) {
        distractors.add('以上各项均不符合');
      }

      // 正确项位置由 i 决定，保证分布均匀
      final pos = i % 4;
      final opts = <String>[];
      var di = 0;
      for (var p = 0; p < 4; p++) {
        if (p == pos) {
          opts.add(correct);
        } else {
          opts.add(distractors[di++]);
        }
      }

      out.add({
        'id': 'gl_${_slug(lesson)}_q$i',
        'subject': 'chinese',
        'grade': '九年级',
        'unit': '文言文注释 · 测验',
        'lesson': lesson,
        'knowledge': star ? '重点注释' : '常规注释',
        'workbook': '自编',
        'type': 'single',
        'stem': '《$lesson》中「${g['word']}」的意思是（ ）',
        'options': opts,
        'answer': String.fromCharCode(65 + pos),
        'analysis': '「${g['word']}」：$correct',
        'difficulty': star ? 3 : 1,
      });
    }
  });

  return out;
}

String _slug(String s) {
  const map = {
    '岳阳楼记': 'yy',
    '醉翁亭记': 'zw',
    '湖心亭看雪': 'hx',
    '曹刿论战': 'cg',
    '邹忌讽齐王纳谏': 'zj',
    '陈涉世家': 'cs',
    '出师表': 'csb',
  };
  return map[s] ?? s.hashCode.toRadixString(16);
}

/// 全部题库汇总
List<Question> buildAllQuestions() {
  final raw = <Map<String, dynamic>>[
    ...politics2026Unit1,
    ...politics2026Unit234,
    ...politicsEssential2026,
    ...history2026Unit14,
    ...history2026Unit57,
    ...historyEssentialUnit14,
    ...historyEssentialUnit57,
    ...chinese2026Unit,
    ...chineseRecite,
    ...buildGlossaryQuestions(),
    ...chemistry2026Unit,
  ];
  return raw.map(Question.fromJson).toList();
}

/// 科目元信息
class SubjectMeta {
  final String key;
  final String label;
  final String icon;
  const SubjectMeta(this.key, this.label, this.icon);
}

const List<SubjectMeta> allSubjects = [
  SubjectMeta('politics', '道德与法治', '⚖️'),
  SubjectMeta('history', '历史', '📜'),
  SubjectMeta('chinese', '语文', '📖'),
  SubjectMeta('chemistry', '化学', '⚗️'),
];

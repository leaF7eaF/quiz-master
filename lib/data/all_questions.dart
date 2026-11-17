import '../models/question.dart';
import 'politics_2026_unit1.dart';
import 'politics_2026_unit234.dart';
import 'politics_essential_2026.dart';
import 'history_2026_unit14.dart';
import 'history_2026_unit57.dart';
import 'history_essential_unit14.dart';
import 'history_essential_unit57.dart';
import 'chinese_2026.dart';
import 'chinese_classical.dart';
import 'chinese_recite.dart';
import 'chemistry_2026.dart';

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
    ...chineseClassical,
    ...chineseRecite,
    ...chemistry2026Unit,
  ];
  return raw.map(Question.fromJson).toList();
}

/// 科目元信息
class SubjectMeta {
  final String key;
  final String label;
  final String icon; // 用 emoji 作简易图标
  const SubjectMeta(this.key, this.label, this.icon);
}

const List<SubjectMeta> allSubjects = [
  SubjectMeta('politics', '道德与法治', '⚖️'),
  SubjectMeta('history', '历史', '📜'),
  SubjectMeta('chinese', '语文', '📖'),
  SubjectMeta('chemistry', '化学', '⚗️'),
];

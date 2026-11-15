// 题目模型 —— 带完整分级维度
class Question {
  final String id;
  final String subject; // politics / history / chinese / chemistry
  final String grade; // 七年级 / 八年级 / 九年级
  final String unit; // 单元 / 模块
  final String knowledge; // 知识点
  final String workbook; // 练习册来源: 五三/必刷题/真题/自编
  final String type; // single / multiple / fill
  final String stem;
  final List<String> options; // 选择题
  final String answer; // 正确选项字母,多选如 "AB"; 填空为标准答案
  final String analysis;
  final int difficulty; // 1-3
  const Question({
    required this.id,
    required this.subject,
    required this.grade,
    required this.unit,
    required this.knowledge,
    this.workbook = '自编',
    required this.type,
    required this.stem,
    this.options = const [],
    required this.answer,
    required this.analysis,
    this.difficulty = 1,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'], subject: j['subject'],
        grade: j['grade'] ?? '九年级', unit: j['unit'] ?? '',
        knowledge: j['knowledge'] ?? '', workbook: j['workbook'] ?? '自编',
        type: j['type'] ?? 'single',
        stem: j['stem'],
        options: (j['options'] as List? ?? []).cast<String>(),
        answer: j['answer'], analysis: j['analysis'] ?? '',
        difficulty: j['difficulty'] ?? 1,
      );
}

// 一次答题记录：题、对错、用时、当天时间戳、所属知识点/练习册
class AnswerRecord {
  final String qid;
  final String subject;
  final String knowledge;
  final String workbook;
  final bool correct;
  final int timeMs;
  final DateTime when;
  const AnswerRecord({
    required this.qid, required this.subject, required this.knowledge,
    required this.workbook, required this.correct, required this.timeMs,
    required this.when,
  });
}

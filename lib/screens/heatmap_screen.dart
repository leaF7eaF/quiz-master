import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/dark_ui.dart';
import '../data/all_questions.dart';

/// 热力图：默认统计全部科目，可筛选单科
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});
  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  /// null = 全部科目
  String? _filterSubject;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();

    // 按筛选条件聚合每日做题数
    final Map<String, int> daily = {};
    int streakN = 0;
    {
      final filtered = _filterSubject == null
          ? p.records
          : p.records.where((r) => r.subject == _filterSubject);
      for (final r in filtered) {
        final k = _ymd(r.when);
        daily[k] = (daily[k] ?? 0) + 1;
      }
      // 连续天数
      final days = daily.keys.toSet();
      var d = DateTime.now();
      if (!days.contains(_ymd(d))) d = d.subtract(const Duration(days: 1));
      while (days.contains(_ymd(d))) {
        streakN++;
        d = d.subtract(const Duration(days: 1));
      }
    }

    // 最近 15 周（105 天），右边界为本周六
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    final end = today0.add(Duration(days: 6 - today0.weekday % 7));
    final start = end.subtract(const Duration(days: 15 * 7 - 1));

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final maxCount = daily.values.fold<int>(1, (a, b) => b > a ? b : a);
    final total = daily.values.fold<int>(0, (a, b) => a + b);

    final title = _filterSubject == null
        ? '做题热力图 · 全部科目'
        : '${quizSubjects.firstWhere((s) => s.key == _filterSubject).label} · 做题热力图';

    // 薄弱知识点跟随筛选科目
    final weakSource = _filterSubject ?? p.subject;
    final weak = p.accuracyByKnowledge.entries.where((e) {
      if (e.value >= 0.6) return false;
      return p.records.any((r) =>
          r.subject == weakSource &&
          (r.knowledge.isEmpty ? '未分类' : r.knowledge) == e.key);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return DarkScaffold(
      title: '热力图',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          Text(_filterSubject == null ? '全部科目' : title,
              style: TextStyle(fontSize: 12, color: DarkC.faint)),
          const SizedBox(height: 10),
          // 科目筛选
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('全部科目', null),
                ...quizSubjects.map((s) => _chip(s.label, s.key)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DarkPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('近 105 天累计 $total 题',
                        style:
                            const TextStyle(fontSize: 13, color: DarkC.sub)),
                    const Spacer(),
                    Text('连续 $streakN 天',
                        style: const TextStyle(
                            fontSize: 13,
                            color: DarkC.green,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  _HeatGrid(days: days, daily: daily, maxCount: maxCount),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('少',
                          style: TextStyle(
                              fontSize: 11, color: DarkC.sub)),
                      const SizedBox(width: 4),
                      ..._legendColors.map((c) => Container(
                            width: 12,
                            height: 12,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )),
                      const SizedBox(width: 4),
                      const Text('多',
                          style: TextStyle(
                              fontSize: 11, color: DarkC.sub)),
                    ],
                  ),
                ],
              ),
          ),
          const SizedBox(height: 18),
          const Text('薄弱知识点',
              style: TextStyle(
                  color: DarkC.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            _filterSubject == null
                ? '全部科目 · 正确率低于 60% 的考点'
                : '${quizSubjects.firstWhere((s) => s.key == _filterSubject).label} · 正确率低于 60% 的考点',
            style: const TextStyle(fontSize: 12, color: DarkC.sub),
          ),
          const SizedBox(height: 10),
          if (weak.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('暂无薄弱点，继续加油',
                    style: TextStyle(color: DarkC.sub)),
              ),
            )
          else
            ...weak.map((e) => _WeakRow(knowledge: e.key, acc: e.value)),
          const SizedBox(height: 18),
          const Text('最近 7 天',
              style: TextStyle(
                  color: DarkC.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._recentWeekRows(daily),
        ],
      ),
    );
  }

  Widget _chip(String label, String? key) {
    final sel = _filterSubject == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterSubject = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: sel
                ? DarkC.green.withOpacity(0.20)
                : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel
                  ? DarkC.green.withOpacity(0.55)
                  : Colors.white.withOpacity(0.14),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: sel ? DarkC.green : DarkC.ink,
              fontSize: 13,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  static const _legendColors = [
    Color(0x1AFFFFFF),
    Color(0x3355C08A),
    Color(0x6655C08A),
    Color(0x9955C08A),
    Color(0xFF5FD08A),
  ];

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Widget> _recentWeekRows(Map<String, int> daily) {
    final out = <Widget>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final key = _ymd(d);
      final c = daily[key] ?? 0;
      out.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(
            width: 78,
            child: Text('${d.month}月${d.day}日',
                style:
                    const TextStyle(fontSize: 12, color: DarkC.sub)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: c == 0 ? 0.0 : (c / 20).clamp(0.05, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: DarkC.track,
                color: DarkC.green,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: Text('$c 题',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.right),
          ),
        ]),
      ));
    }
    return out;
  }
}

class _HeatGrid extends StatelessWidget {
  final List<DateTime> days;
  final Map<String, int> daily;
  final int maxCount;
  const _HeatGrid(
      {required this.days, required this.daily, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final weeks = <List<DateTime>>[];
    var cur = <DateTime>[];
    for (final d in days) {
      cur.add(d);
      if (cur.length == 7) {
        weeks.add(cur);
        cur = [];
      }
    }
    if (cur.isNotEmpty) weeks.add(cur);

    final palette = [
      const Color(0x1AFFFFFF),
      const Color(0x3355C08A),
      const Color(0x6655C08A),
      const Color(0x9955C08A),
      const Color(0xFF5FD08A),
    ];
    Color colorFor(int count) {
      if (count <= 0) return palette[0];
      final r = count / maxCount;
      if (r <= 0.25) return palette[1];
      if (r <= 0.5) return palette[2];
      if (r <= 0.75) return palette[3];
      return palette[4];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.map((w) {
          return Column(
            children: w.map((d) {
              final key =
                  '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final c = daily[key] ?? 0;
              return Container(
                width: 13,
                height: 13,
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: colorFor(c),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _WeakRow extends StatelessWidget {
  final String knowledge;
  final double acc;
  const _WeakRow({required this.knowledge, required this.acc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Text(knowledge, style: const TextStyle(fontSize: 14)),
        ),
        SizedBox(
          width: 110,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: acc,
              minHeight: 7,
              backgroundColor: DarkC.track,
              color: acc < 0.4 ? DarkC.red : DarkC.orange,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text('${(acc * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}

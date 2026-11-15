import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../data/all_questions.dart';

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final daily = p.dailyCounts;
    final meta = allSubjects.firstWhere((s) => s.key == p.subject,
        orElse: () => allSubjects.first);

    // 最近 15 周（105 天），从周日对齐
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    // 找到本周末（周六）作为右边界，再往前推 15 周
    final end = today0.add(Duration(days: 6 - today0.weekday % 7));
    final start = end.subtract(const Duration(days: 15 * 7 - 1));

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final maxCount = daily.values.fold<int>(1, (a, b) => b > a ? b : a);
    final total = daily.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text('${meta.icon} ${meta.label} · 做题热力图'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('近 ${total} 天累计 $total 题',
                        style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
                    const Spacer(),
                    Text('连续 ${p.streak} 天',
                        style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  _HeatGrid(days: days, daily: daily, maxCount: maxCount),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('少', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                      const SizedBox(width: 4),
                      ..._legendColors.map((c) => Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )),
                      const SizedBox(width: 4),
                      const Text('多', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('薄弱知识点', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('正确率低于 60% 的考点，按薄弱程度排序',
              style: TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 10),
          if (p.weakKnowledges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('暂无薄弱点，继续加油', style: TextStyle(color: AppTheme.muted)),
              ),
            )
          else
            ...p.weakKnowledges.map((e) => _WeakRow(knowledge: e.key, acc: e.value)),
          const SizedBox(height: 18),
          const Text('做题量分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._recentWeekRows(daily),
        ],
      ),
    );
  }

  static const _legendColors = [
    Color(0xFFEBEDF0),
    Color(0xFFC6E1CE),
    Color(0xFF8FC4A2),
    Color(0xFF4E9C6E),
    Color(0xFF2F6B4F),
  ];

  Color _colorFor(int count, int maxCount) {
    if (count <= 0) return _legendColors[0];
    final ratio = count / maxCount;
    if (ratio <= 0.25) return _legendColors[1];
    if (ratio <= 0.5) return _legendColors[2];
    if (ratio <= 0.75) return _legendColors[3];
    return _legendColors[4];
  }

  List<Widget> _recentWeekRows(Map<String, int> daily) {
    // 最近 7 天
    final out = <Widget>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final c = daily[key] ?? 0;
      out.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(
            width: 78,
            child: Text('${d.month}月${d.day}日',
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: c == 0 ? 0.0 : (c / 20).clamp(0.05, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: AppTheme.line,
                color: AppTheme.primary,
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
  const _HeatGrid({required this.days, required this.daily, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    // 按周分列
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
      const Color(0xFFEBEDF0),
      const Color(0xFFC6E1CE),
      const Color(0xFF8FC4A2),
      const Color(0xFF4E9C6E),
      const Color(0xFF2F6B4F),
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
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
              backgroundColor: AppTheme.line,
              color: acc < 0.4 ? Colors.red.shade400 : AppTheme.accent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text('${(acc * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}

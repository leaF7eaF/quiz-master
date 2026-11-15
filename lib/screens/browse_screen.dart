import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'practice_screen.dart';

enum BrowseDim { unit, knowledge, workbook, all }

class BrowseScreen extends StatefulWidget {
  final bool initialPick;
  const BrowseScreen({super.key, this.initialPick = false});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  BrowseDim _dim = BrowseDim.unit;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final list = p.filteredQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(_dimTitle(_dim)),
        actions: [
          if (p.filterUnit != null || p.filterKnowledge != null || p.filterWorkbook != null)
            TextButton(
              onPressed: () {
                p.setFilterUnit(null);
                p.setFilterKnowledge(null);
                p.setFilterWorkbook(null);
              },
              child: const Text('清除筛选'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 维度切换
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: BrowseDim.values.map((d) {
                final sel = d == _dim;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_dimLabel(d)),
                    selected: sel,
                    onSelected: (_) => setState(() => _dim = d),
                    showCheckmark: false,
                    selectedColor: AppTheme.primary.withOpacity(0.14),
                    labelStyle: TextStyle(
                        color: sel ? AppTheme.primary : AppTheme.ink,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          if (_dim == BrowseDim.all) ...[
            // 全部题目
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text('共 ${list.length} 题', style: const TextStyle(color: AppTheme.muted)),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: list.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                                questions: (List.of(list)..shuffle()), title: '整组练习'),
                          )),
                  child: const Text('开始练习'),
                ),
              ]),
            ),
            Expanded(child: _QuestionList(qs: list)),
          ] else ...[
            // 分类列表
            Expanded(child: _groupList(p)),
          ],
        ],
      ),
    );
  }

  Widget _groupList(QuizProvider p) {
    final counts = <String, int>{};
    for (final q in p.currentSubjectQuestions) {
      final key = switch (_dim) {
        BrowseDim.unit => q.unit,
        BrowseDim.knowledge => q.knowledge,
        BrowseDim.workbook => q.workbook,
        BrowseDim.all => '',
      };
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final keys = counts.keys.toList()..sort();

    if (keys.isEmpty) {
      return const Center(child: Text('暂无题目'));
    }

    return ListView.separated(
      itemCount: keys.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (_, i) {
        final k = keys[i];
        return ListTile(
          title: Text(k, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text('${counts[k]} 题', style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.muted),
          onTap: () {
            final qs = p.currentSubjectQuestions.where((q) {
              return switch (_dim) {
                BrowseDim.unit => q.unit == k,
                BrowseDim.knowledge => q.knowledge == k,
                BrowseDim.workbook => q.workbook == k,
                BrowseDim.all => true,
              };
            }).toList()
              ..shuffle();
            if (qs.isEmpty) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => PracticeScreen(questions: qs, title: k)));
          },
        );
      },
    );
  }

  String _dimTitle(BrowseDim d) => switch (d) {
        BrowseDim.unit => '按单元',
        BrowseDim.knowledge => '按知识点',
        BrowseDim.workbook => '按来源',
        BrowseDim.all => '全部题目',
      };

  String _dimLabel(BrowseDim d) => switch (d) {
        BrowseDim.unit => '单元',
        BrowseDim.knowledge => '知识点',
        BrowseDim.workbook => '来源',
        BrowseDim.all => '全部',
      };
}

class _QuestionList extends StatelessWidget {
  final List qs;
  const _QuestionList({required this.qs});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: qs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (_, i) {
        final q = qs[i];
        return ListTile(
          dense: true,
          title: Text(q.stem, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
          subtitle: Text('${q.unit} · ${q.knowledge}', style: const TextStyle(fontSize: 11)),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => PracticeScreen(questions: [q], title: '单题查看'))),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import 'practice_screen.dart';

enum BrowseDim { unit, workbook, all }

/// 题库：单元 → 课 两级目录
class BrowseScreen extends StatefulWidget {
  final bool initialPick;
  const BrowseScreen({super.key, this.initialPick = false});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  BrowseDim _dim = BrowseDim.unit;

  /// 当前进入的单元（null = 单元列表页）
  String? _openUnit;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();

    // 课列表页
    if (_dim == BrowseDim.unit && _openUnit != null) {
      return _LessonPage(
        unit: _openUnit!,
        onBack: () => setState(() => _openUnit = null),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_dim == BrowseDim.all ? '全部题目' : (_dim == BrowseDim.unit ? '按目录' : '按来源')),
      ),
      body: Column(
        children: [
          // 维度切换（去掉知识点）
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
                    onSelected: (_) => setState(() {
                      _dim = d;
                      _openUnit = null;
                    }),
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
          Expanded(
            child: _dim == BrowseDim.all ? _allList(p) : _groupList(p),
          ),
        ],
      ),
    );
  }

  // ===== 全部题目 =====
  Widget _allList(QuizProvider p) {
    final list = p.filteredQuestions;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Text('共 ${list.length} 题',
                style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
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
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) {
              final q = list[i];
              return ListTile(
                dense: true,
                title: Text(q.stem,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14)),
                subtitle: Text('${q.unit} · ${q.lesson}',
                    style: const TextStyle(fontSize: 11)),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PracticeScreen(questions: [q], title: '单题查看'))),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===== 单元列表 / 来源列表 =====
  Widget _groupList(QuizProvider p) {
    final items = <String, int>{};
    for (final q in p.currentSubjectQuestions) {
      final k = _dim == BrowseDim.unit ? q.unit : q.workbook;
      items[k] = (items[k] ?? 0) + 1;
    }
    final keys = items.keys.toList()
      ..sort((a, b) =>
          QuizProvider.cnNumValue(a).compareTo(QuizProvider.cnNumValue(b)));

    if (keys.isEmpty) return const Center(child: Text('暂无题目'));

    return ListView.separated(
      itemCount: keys.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (_, i) {
        final k = keys[i];
        final sub = _dim == BrowseDim.unit
            ? '${items[k]} 题 · ${p.lessonsOf(k).length} 课'
            : '${items[k]} 题';
        return ListTile(
          title: Text(k,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
          trailing:
              const Icon(Icons.chevron_right, size: 20, color: AppTheme.muted),
          onTap: () {
            if (_dim == BrowseDim.unit) {
              setState(() => _openUnit = k);
            } else {
              final qs = p.currentSubjectQuestions
                  .where((q) => q.workbook == k)
                  .toList()
                ..shuffle();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          PracticeScreen(questions: qs, title: k)));
            }
          },
        );
      },
    );
  }

  String _dimLabel(BrowseDim d) => switch (d) {
        BrowseDim.unit => '目录',
        BrowseDim.workbook => '来源',
        BrowseDim.all => '全部',
      };
}

/// 单元内的课列表页
class _LessonPage extends StatelessWidget {
  final String unit;
  final VoidCallback onBack;
  const _LessonPage({required this.unit, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final lessons = p.lessonsOf(unit);
    final total = p.currentSubjectQuestions.where((q) => q.unit == unit).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: Text(unit, style: const TextStyle(fontSize: 15)),
      ),
      body: Column(
        children: [
          // 整单元练习
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.playlist_play, size: 20),
                label: Text('整单元练习（$total 题）'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final qs = p.currentSubjectQuestions
                      .where((q) => q.unit == unit)
                      .toList()
                    ..shuffle();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PracticeScreen(questions: qs, title: unit)));
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: lessons.isEmpty
                ? const Center(child: Text('本单元暂无分课数据'))
                : ListView.separated(
                    itemCount: lessons.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) {
                      final les = lessons[i];
                      final qs = p.questionsOfLesson(unit, les);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppTheme.primary.withOpacity(0.12),
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        title: Text(les,
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w500)),
                        subtitle: Text('${qs.length} 题',
                            style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.play_arrow,
                            size: 22, color: AppTheme.primary),
                        onTap: () {
                          if (qs.isEmpty) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PracticeScreen(
                                      questions: (List.of(qs)..shuffle()),
                                      title: les)));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

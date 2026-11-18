import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../data/all_questions.dart';
import '../theme/app_theme.dart';
import 'practice_screen.dart';
import 'browse_screen.dart';
import 'wrong_pick_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('刷题本'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _TodayCard(p: p),
          const SizedBox(height: 20),
          const Text('选择科目', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...allSubjects.map((s) => _SubjectRow(meta: s, p: p)),
          const SizedBox(height: 12),
          const Text('快捷练习', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _QuickBtn(
                icon: Icons.shuffle,
                label: '随机 10 题',
                onTap: () {
                  final qs = List.of(p.currentSubjectQuestions)..shuffle();
                  if (qs.isEmpty) return;
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PracticeScreen(questions: qs.take(10).toList(), title: '随机练习')));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickBtn(
                icon: Icons.error_outline,
                label: '错题重练',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WrongPickScreen())),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final QuizProvider p;
  const _TodayCard({required this.p});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日已练', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${p.todayCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700, height: 1)),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('题', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('连续 ${p.streak} 天',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('累计正确率 ${(p.accuracy * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final SubjectMeta meta;
  final QuizProvider p;
  const _SubjectRow({required this.meta, required this.p});

  @override
  Widget build(BuildContext context) {
    final total = p.all.where((q) => q.subject == meta.key).length;
    final done = p.records.where((r) => r.subject == meta.key).length;
    final correct = p.records.where((r) => r.subject == meta.key && r.correct).length;
    final acc = done == 0 ? 0.0 : correct / done;
    final selected = p.subject == meta.key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // 点击只切换科目，不自动跳转
        onTap: () => p.selectSubject(meta.key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withOpacity(0.06) : Colors.white,
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(meta.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meta.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('$total 题 · 已做 $done 题 · 正确率 ${(acc * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                ),
              ),
              // 明确入口：进入题库（点卡片本身只是切科目）
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    p.selectSubject(meta.key);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BrowseScreen()));
                  },
                  child: Text(
                    '题库',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }
}

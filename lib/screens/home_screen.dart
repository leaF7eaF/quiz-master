import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/english_provider.dart';
import 'phrase_home_screen.dart';
import '../data/all_questions.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'practice_screen.dart';
import 'browse_screen.dart';
import 'wrong_pick_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
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
    // 液态玻璃 + 墨绿染色：保留强调感，又和整体玻璃风格统一
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 24,
      blur: 30,
      tint: AppTheme.primary.withOpacity(0.88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('今日已练',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('连续 ${p.streak} 天',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${p.todayCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1)),
              const Padding(
                padding: EdgeInsets.only(bottom: 7, left: 5),
                child: Text('题',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('累计正确率 ${(p.accuracy * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
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

  bool get _isEnglish => meta.key == 'english';

  @override
  Widget build(BuildContext context) {
    final eng = context.watch<EnglishProvider>();
    final total = _isEnglish
        ? eng.total
        : p.all.where((q) => q.subject == meta.key).length;
    final done = _isEnglish
        ? eng.learnedCount
        : p.records.where((r) => r.subject == meta.key).length;
    final correct = p.records.where((r) => r.subject == meta.key && r.correct).length;
    final acc = done == 0 ? 0.0 : correct / done;
    final selected = !_isEnglish && p.subject == meta.key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // 点科目 = 我要去做这科的题，直接跳转选题页
        onTap: () {
          if (_isEnglish) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PhraseHomeScreen()));
          } else {
            p.selectSubject(meta.key);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BrowseScreen()));
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          radius: 12,
          tint: selected
              ? AppTheme.primary.withOpacity(0.10)
              : Colors.white.withOpacity(0.55),
          bordered: true,
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
                    Text(
                        _isEnglish
                            ? '$total 个短语 · 已学 $done 个'
                            : '$total 题 · 已做 $done 题 · 正确率 ${(acc * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.muted, size: 20),
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
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        radius: 12,
        bordered: true,
        child: Column(children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }
}

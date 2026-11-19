import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/all_questions.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'practice_screen.dart';

/// 错题重练：先选科目，再练该科错题（不依赖首页当前选中的科目）
class WrongPickScreen extends StatelessWidget {
  const WrongPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final counts = p.wrongCountBySubject;
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('错题重练')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 44, color: AppTheme.muted),
                    SizedBox(height: 10),
                    Text('还没有错题', style: TextStyle(color: AppTheme.muted)),
                  ],
                ),
              ),
            )
          else ...[
            // 全部科目混合练
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.shuffle, size: 20),
                label: Text('全部科目混合练（$total 题）'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  final qs = <Question>[];
                  for (final s in quizSubjects) {
                    qs.addAll(p.wrongQuestionsOf(s.key));
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeScreen(
                        questions: qs..shuffle(),
                        title: '错题重练 · 全部',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('按科目练',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...quizSubjects.map((s) {
              final c = counts[s.key] ?? 0;
              final enabled = c > 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: enabled
                      ? () {
                          final qs = p.wrongQuestionsOf(s.key)..shuffle();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PracticeScreen(
                                  questions: qs,
                                  title: '错题重练 · ${s.label}'),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      border: Border.all(color: AppTheme.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(s.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: enabled ? AppTheme.ink : AppTheme.muted,
                            ),
                          ),
                        ),
                        Text(
                          enabled ? '$c 题' : '无错题',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: enabled ? AppTheme.primary : AppTheme.muted,
                            fontWeight:
                                enabled ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: enabled ? AppTheme.muted : AppTheme.line,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

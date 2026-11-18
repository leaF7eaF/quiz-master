import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'practice_screen.dart';

class WrongScreen extends StatelessWidget {
  const WrongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final wrongs = p.wrongQuestions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('错题本')),
      body: wrongs.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 44, color: AppTheme.muted),
                  SizedBox(height: 10),
                  Text('当前科目还没有错题', style: TextStyle(color: AppTheme.muted)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Text('共 ${wrongs.length} 道',
                        style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('重练全部'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PracticeScreen(
                            questions: (List.of(wrongs)..shuffle()), title: '错题重练')),
                      ),
                    ),
                  ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: wrongs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) {
                      final q = wrongs[i];
                      return ListTile(
                        title: Text(q.stem,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text('${q.unit} · ${q.knowledge}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right,
                            size: 20, color: AppTheme.muted),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PracticeScreen(questions: [q], title: '错题查看')),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

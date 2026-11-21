import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/dark_ui.dart';
import 'practice_screen.dart';

class WrongScreen extends StatelessWidget {
  const WrongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final wrongs = p.wrongQuestions;

    return DarkScaffold(
      title: '错题本',
      body: wrongs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 44, color: DarkC.faint),
                  const SizedBox(height: 12),
                  Text('当前科目还没有错题',
                      style: TextStyle(color: DarkC.sub, fontSize: 13)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
                  child: Row(children: [
                    Text('共 ${wrongs.length} 道',
                        style: TextStyle(color: DarkC.sub, fontSize: 13)),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        foregroundColor: DarkC.ink,
                      ),
                      icon: const Icon(Icons.replay, size: 17),
                      label: const Text('重练全部',
                          style: TextStyle(fontSize: 13)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                                questions: (List.of(wrongs)..shuffle()),
                                title: '错题重练')),
                      ),
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: wrongs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final q = wrongs[i];
                      return DarkPanel(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PracticeScreen(
                                  questions: [q], title: '错题查看')),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(q.stem,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: DarkC.ink,
                                          fontSize: 14,
                                          height: 1.4)),
                                  const SizedBox(height: 5),
                                  Text('${q.unit} · ${q.knowledge}',
                                      style: TextStyle(
                                          fontSize: 11, color: DarkC.faint)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 20, color: DarkC.faint),
                          ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'archive_screen.dart';
import 'changelog_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final acc = p.accuracyByKnowledge.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('学习统计'), actions: [
        IconButton(
          tooltip: '存档备份',
          icon: const Icon(Icons.cloud_sync_outlined),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ArchiveScreen())),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              _metric('总答题', '${p.totalAnswered}', '题'),
              const SizedBox(width: 10),
              _metric('答对', '${p.totalCorrect}', '题'),
              const SizedBox(width: 10),
              _metric('正确率', (p.accuracy * 100).toStringAsFixed(0), '%'),
            ],
          ),
          const SizedBox(height: 18),
          const Text('各知识点正确率', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (acc.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('还没有答题记录', style: TextStyle(color: AppTheme.muted))),
            )
          else
            ...acc.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: e.value,
                          minHeight: 7,
                          backgroundColor: AppTheme.line,
                          color: e.value >= 0.8
                              ? AppTheme.primary
                              : e.value >= 0.6
                                  ? AppTheme.accent
                                  : Colors.red.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      child: Text('${(e.value * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
                    ),
                  ]),
                )),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('清空所有记录'),
                  content: const Text('将删除全部答题记录和热力图数据，题库不受影响。确定吗？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('清空')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await p.resetAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('已清空')));
                }
              }
            },
            child: const Text('清空答题记录'),
          ),

        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChangelogScreen())),
            child: const Text(
              '版本 ${const String.fromEnvironment("APP_VERSION", defaultValue: "dev")} · 更新日志',
              style: TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _metric(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1)),
              Padding(
                padding: const EdgeInsets.only(left: 1, bottom: 2),
                child: Text(unit, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        ]),
      ),
    );
  }
}

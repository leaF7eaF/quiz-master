import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/dark_ui.dart';
import 'archive_screen.dart';
import 'changelog_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final acc = p.accuracyByKnowledge.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DarkScaffold(
      title: '学习统计',
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_sync_outlined, color: DarkC.sub),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ArchiveScreen())),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
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
          const SizedBox(height: 22),
          const Text('各知识点正确率',
              style: TextStyle(
                  color: DarkC.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          DarkPanel(
            child: acc.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                        child: Text('还没有答题记录',
                            style: TextStyle(
                                color: DarkC.faint, fontSize: 13))),
                  )
                : Column(
                    children: acc
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(children: [
                                Expanded(
                                    child: Text(e.key,
                                        style: const TextStyle(
                                            color: DarkC.ink,
                                            fontSize: 13))),
                                SizedBox(
                                  width: 96,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: e.value,
                                      minHeight: 6,
                                      backgroundColor: DarkC.track,
                                      color: e.value >= 0.8
                                          ? DarkC.green
                                          : e.value >= 0.6
                                              ? DarkC.orange
                                              : DarkC.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                      '${(e.value * 100).toStringAsFixed(0)}%',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: DarkC.sub, fontSize: 12)),
                                ),
                              ]),
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 24),
          DarkPanel(
            padding: EdgeInsets.zero,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2C24),
                  title: const Text('清空所有记录',
                      style: TextStyle(color: DarkC.ink)),
                  content: Text('将删除全部答题记录和热力图数据，题库不受影响。确定吗？',
                      style: TextStyle(color: DarkC.sub, height: 1.5)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('清空',
                            style: TextStyle(color: DarkC.red))),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await p.resetAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清空')));
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Text('清空答题记录',
                    style: TextStyle(color: DarkC.red, fontSize: 14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChangelogScreen())),
              child: Text(
                '版本 ${const String.fromEnvironment("APP_VERSION", defaultValue: "dev")} · 更新日志',
                style: TextStyle(fontSize: 11, color: DarkC.faint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String unit) {
    return Expanded(
      child: DarkPanel(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: DarkC.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1)),
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 2),
                child: Text('',
                    style: TextStyle(fontSize: 11, color: DarkC.sub)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(fontSize: 11, color: DarkC.sub)),
        ]),
      ),
    );
  }
}

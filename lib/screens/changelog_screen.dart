import 'package:flutter/material.dart';
import '../data/changelog.dart';
import '../theme/app_theme.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('更新日志')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appChangelog.length,
        itemBuilder: (_, i) {
          final e = appChangelog[i];
          final isLatest = i == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧版本标记
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: isLatest ? AppTheme.primary : AppTheme.line,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i != appChangelog.length - 1)
                      Container(
                          width: 1, height: 70, color: AppTheme.line),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('v${e.version}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isLatest
                                    ? AppTheme.primary
                                    : AppTheme.ink)),
                        if (isLatest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('当前',
                                style: TextStyle(
                                    fontSize: 9, color: Colors.white)),
                          ),
                        ],
                        const Spacer(),
                        Text(e.date,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.muted)),
                      ]),
                      const SizedBox(height: 6),
                      ...e.changes.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 6),
                                  child: SizedBox(
                                    width: 3,
                                    height: 3,
                                    child: DecoratedBox(
                                        decoration: BoxDecoration(
                                            color: AppTheme.muted,
                                            shape: BoxShape.circle)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(c,
                                      style: const TextStyle(
                                          fontSize: 13, height: 1.5)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

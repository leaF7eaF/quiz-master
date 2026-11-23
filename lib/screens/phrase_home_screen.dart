import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../widgets/dark_ui.dart';
import 'phrase_book_screen.dart';

/// 英语短语：词书选择
class PhraseHomeScreen extends StatelessWidget {
  const PhraseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnglishProvider>();
    const allKey = 'all';
    final grand = p.totalOf(allKey);

    return DarkScaffold(
      title: '英语短语',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // 数据概览
          _StatsCard(p: p),
          const SizedBox(height: 24),
          Text('选择词书',
              style: TextStyle(
                  fontSize: 13,
                  color: DarkC.sub,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...phraseBooks.map((book) {
            final total = p.totalOf(book.key);
            final learned = p.learnedOf(book.key);
            final isCurrent = p.bookKey == book.key;
            final full = total > 0 && learned >= total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DarkPanel(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                radius: 18,
                onTap: () async {
                  await p.selectBook(book.key);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhraseBookScreen()),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(book.label,
                                  style: const TextStyle(
                                      color: DarkC.ink,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: DarkC.green.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('当前',
                                      style: TextStyle(
                                          fontSize: 10, color: DarkC.green)),
                                ),
                              ],
                              if (full) ...[
                                const SizedBox(width: 6),
                                Text('已学完',
                                    style: TextStyle(
                                        fontSize: 10, color: DarkC.green)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text('$total 个 · 已学 $learned',
                              style: TextStyle(
                                  fontSize: 12, color: DarkC.sub)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : learned / total,
                              minHeight: 4,
                              backgroundColor: DarkC.track,
                              color: DarkC.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right,
                        size: 20, color: DarkC.faint),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          DarkPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 15, color: DarkC.faint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '同一短语在任何词书中学过，其他词书自动识别为已学。'
                    '全部 $grand 个短语共享一套进度。',
                    style: TextStyle(
                        fontSize: 12, height: 1.6, color: DarkC.sub),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 学习数据概览（今日 / 累计 / 连续 / 最近 7 天）
class _StatsCard extends StatelessWidget {
  final EnglishProvider p;
  const _StatsCard({required this.p});

  @override
  Widget build(BuildContext context) {
    final days = p.recentDays(7);
    final maxV = days.fold<int>(1, (a, e) => e.value > a ? e.value : a);
    const week = ['一', '二', '三', '四', '五', '六', '日'];

    return DarkPanel(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _metric('今日学习', '${p.todayLearned}', '个')),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.10)),
              const SizedBox(width: 16),
              Expanded(child: _metric('今日时长', '${p.todayMinutes}', '分钟')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _metric('累计学习', '${p.totalLearnedAll}', '个')),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.10)),
              const SizedBox(width: 16),
              Expanded(
                child: _metric(
                    '累计时长',
                    p.totalMinutes >= 60
                        ? (p.totalMinutes / 60).toStringAsFixed(1)
                        : '${p.totalMinutes}',
                    p.totalMinutes >= 60 ? '小时' : '分钟'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _metric('连续学习', '${p.streak}', '天')),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((e) {
              final on = e.value > 0;
              final r = e.value / maxV;
              return Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on
                          ? DarkC.green.withOpacity(0.15 + r * 0.65)
                          : Colors.white.withOpacity(0.07),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${e.key.day}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: on ? FontWeight.w600 : FontWeight.normal,
                        color: on ? const Color(0xFF06240F) : DarkC.faint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(week[e.key.weekday - 1],
                      style: TextStyle(fontSize: 10, color: DarkC.faint)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5, color: DarkC.sub)),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: const TextStyle(
                    color: DarkC.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1)),
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 3),
              child: Text(unit,
                  style: TextStyle(fontSize: 10, color: DarkC.sub)),
            ),
          ],
        ),
      ],
    );
  }
}

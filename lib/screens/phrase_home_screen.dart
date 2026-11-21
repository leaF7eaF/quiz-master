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

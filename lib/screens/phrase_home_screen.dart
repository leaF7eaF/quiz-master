import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'phrase_book_screen.dart';

/// 英语短语：词书选择
class PhraseHomeScreen extends StatelessWidget {
  const PhraseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnglishProvider>();
    final totalAll = phraseBooks
        .firstWhere((b) => b.key == 'all')
        .key;
    final grand = p.totalOf(totalAll);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(title: const Text('英语短语')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('选择词书',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...phraseBooks.map((book) {
            final total = p.totalOf(book.key);
            final learned = p.learnedOf(book.key);
            final isCurrent = p.bookKey == book.key;
            final full = total > 0 && learned >= total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await p.selectBook(book.key);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhraseBookScreen()),
                  );
                },
                child: GlassCard(
                  bordered: true,
                  tint: isCurrent
                      ? AppTheme.primary.withOpacity(0.10)
                      : Colors.white.withOpacity(0.55),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                if (book.key == 'all') ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text('全部',
                                        style: TextStyle(
                                            fontSize: 9.5,
                                            color: AppTheme.accent)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$total 个 · 已学 $learned'
                              '${full ? ' · 已学完' : ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.muted),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : learned / total,
                                minHeight: 5,
                                backgroundColor: AppTheme.line,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.chevron_right,
                          size: 20, color: AppTheme.muted),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          GlassCard(
            bordered: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppTheme.muted),
                    const SizedBox(width: 6),
                    Text('关于进度',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '同一短语在任何词书中学过，其他词书自动识别为已学，无需重复学。'
                  '全部 $grand 个短语共享一套进度。',
                  style: TextStyle(
                      fontSize: 12, height: 1.6, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

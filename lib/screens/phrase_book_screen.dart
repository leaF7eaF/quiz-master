import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'phrase_learn_screen.dart';
import 'phrase_review_screen.dart';

/// 某本词书：未学完→学习；学完→总复习
class PhraseBookScreen extends StatelessWidget {
  const PhraseBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnglishProvider>();
    final total = p.total;
    final learned = p.learnedCount;
    final finished = p.allLearned;
    final reviewLeft = p.reviewPool.length;
    final mastered = p.masteredList.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(p.currentBook.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 总进度
          GlassCard(
            bordered: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('外研版 · ${p.currentBook.desc}',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.muted)),
                    const Spacer(),
                    Text('$learned / $total',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : learned / total,
                    minHeight: 8,
                    backgroundColor: AppTheme.line,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  finished ? '已全部学完 🎉' : '还有 ${total - learned} 个短语没学',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (!finished) ...[
            // ===== 学习入口 =====
            _BigButton(
              title: '学习新短语',
              subtitle: '每次 ${p.newPerDay} 个 · 三轮过关',
              icon: Icons.school_outlined,
              color: AppTheme.primary,
              onTap: () {
                final batch = p.nextBatch();
                if (batch.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhraseLearnScreen(batch: batch),
                  ),
                );
              },
            ),
          ] else ...[
            // ===== 总复习入口 =====
            if (reviewLeft > 0) ...[
              _BigButton(
                title: '总复习',
                subtitle: '还剩 $reviewLeft 个未掌握',
                icon: Icons.refresh,
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PhraseReviewScreen(),
                  ),
                ),
              ),
            ] else ...[
              GlassCard(
                bordered: false,
                child: Column(
                  children: [
                    const Icon(Icons.verified, size: 40, color: AppTheme.primary),
                    const SizedBox(height: 10),
                    const Text('全部掌握！',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$mastered 个短语已通过总复习',
                        style: TextStyle(
                            fontSize: 12.5, color: AppTheme.muted)),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 22),
          // 统计
          GlassCard(
            bordered: false,
            child: Column(
              children: [
                _statRow('短语总数', '$total'),
                const Divider(height: 18),
                _statRow('已学完', '$learned'),
                const Divider(height: 18),
                _statRow('已掌握（总复习通过）', '$mastered'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary)),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BigButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

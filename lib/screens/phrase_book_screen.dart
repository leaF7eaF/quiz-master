import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../widgets/dark_ui.dart';
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
    final mastered = p.masteredCount;

    return DarkScaffold(
      title: p.currentBook.label,
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // 总进度
          DarkPanel(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('外研版 · ${p.currentBook.desc}',
                          style: TextStyle(
                              fontSize: 12, color: DarkC.sub)),
                    ),
                    Text('$learned / $total',
                        style: TextStyle(
                            fontSize: 12,
                            color: DarkC.green,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : learned / total,
                    minHeight: 5,
                    backgroundColor: DarkC.track,
                    color: DarkC.green,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  finished ? '已全部学完' : '还有 ${total - learned} 个短语没学',
                  style: const TextStyle(
                      color: DarkC.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!finished) ...[
            _BigButton(
              title: '学习新短语',
              subtitle: (() {
                final done = p.todayLearned;
                final target = p.newPerDay;
                return done >= target
                    ? '今日已完成 $done/$target · 可继续学'
                    : '今日 $done/$target · 三轮过关';
              })(),
              icon: Icons.school_outlined,
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
            const SizedBox(height: 10),
            // 滚动复习：复习最近学过的
            if (learned > 0)
              Builder(builder: (context) {
                final canReview = p.reviewableToday;
                return _BigButton(
                  title: '滚动复习',
                  // 不限额：今日能复习多少就复习多少
                  subtitle: canReview == 0
                      ? '今日复习已完成'
                      : '复习今日可复习的 $canReview 个',
                  icon: Icons.replay,
                  subtle: true,
                  enabled: canReview > 0,
                  onTap: () {
                    final qs = p.recentLearned(canReview);
                    if (qs.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PhraseReviewScreen(queue: qs, title: '滚动复习'),
                      ),
                    );
                  },
                );
              }),
            const SizedBox(height: 12),
            // 学习计划
            DarkPanel(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              radius: 18,
              onTap: () => _editPlan(context, p),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('每天学习',
                            style:
                                TextStyle(fontSize: 12, color: DarkC.sub)),
                        const SizedBox(height: 4),
                        Text('${p.newPerDay} 个',
                            style: const TextStyle(
                                color: DarkC.ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: Colors.white.withOpacity(0.10),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('预计完成',
                            style:
                                TextStyle(fontSize: 12, color: DarkC.sub)),
                        const SizedBox(height: 4),
                        Text('${p.estimatedDays(p.newPerDay)} 天',
                            style: TextStyle(
                                color: DarkC.green,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 18, color: DarkC.faint),
                ],
              ),
            ),
          ] else ...[
            if (reviewLeft > 0)
              _BigButton(
                title: '总复习',
                subtitle: '还剩 $reviewLeft 个未掌握',
                icon: Icons.refresh,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PhraseReviewScreen()),
                ),
              )
            else
              DarkPanel(
                padding: const EdgeInsets.symmetric(vertical: 28),
                radius: 18,
                child: Column(
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 38, color: DarkC.green),
                    const SizedBox(height: 12),
                    const Text('全部掌握',
                        style: TextStyle(
                            color: DarkC.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$mastered 个短语已通过总复习',
                        style:
                            TextStyle(fontSize: 12, color: DarkC.sub)),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 22),
          // 统计
          DarkPanel(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                _statRow('短语总数', '$total'),
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                _statRow('已学完', '$learned'),
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                _statRow('已掌握（总复习通过）', '$mastered'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: DarkC.ink, fontSize: 13.5)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: DarkC.green,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// 修改每天学习量：直接输入数字
  Future<void> _editPlan(BuildContext context, EnglishProvider p) async {
    final ctrl = TextEditingController(text: '${p.newPerDay}');
    final pending = p.pendingCount;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2C24),
        title: const Text('每天学习多少',
            style: TextStyle(color: DarkC.ink, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: DarkC.ink),
              decoration: InputDecoration(
                suffixText: '个',
                suffixStyle: TextStyle(color: DarkC.sub),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: DarkC.green),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('还剩 $pending 个没学',
                style: TextStyle(fontSize: 12.5, color: DarkC.sub)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: DarkC.sub)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DarkC.green),
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null && n > 0) {
                p.setNewPerDay(n);
              }
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  /// 低调样式（用于次要入口）
  final bool subtle;

  /// 是否可点（false 时变灰）
  final bool enabled;

  const _BigButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.subtle = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = subtle ? DarkC.ink : DarkC.green;
    final bgc = subtle
        ? Colors.white.withOpacity(0.07)
        : DarkC.green.withOpacity(0.18);
    final bdc = subtle
        ? Colors.white.withOpacity(0.12)
        : DarkC.green.withOpacity(0.45);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
      color: bgc,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 18, vertical: subtle ? 15 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: bdc),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: subtle ? 20 : 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: DarkC.ink,
                            fontSize: subtle ? 15 : 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(fontSize: 12, color: DarkC.sub)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: DarkC.faint),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

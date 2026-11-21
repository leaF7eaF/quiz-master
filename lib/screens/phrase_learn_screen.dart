import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animate.dart';
import '../widgets/glass.dart';
import '../utils/sound_fx.dart';

/// 新学：一批短语走三轮
/// 第1轮 英→中（带例句提示）
/// 第2轮 英→中
/// 第3轮 中→英
class PhraseLearnScreen extends StatefulWidget {
  final List<Phrase> batch;
  const PhraseLearnScreen({super.key, required this.batch});

  @override
  State<PhraseLearnScreen> createState() => _PhraseLearnScreenState();
}

class _PhraseLearnScreenState extends State<PhraseLearnScreen> {
  int _round = 1; // 1/2/3
  int _idx = 0;
  int? _picked;
  bool _answered = false;
  final Stopwatch _sw = Stopwatch()..start();

  Phrase get _p => widget.batch[_idx];
  bool get _isEnToCn => _round <= 2;

  List<String> get _options {
    final p = context.read<EnglishProvider>();
    final distract = _isEnToCn
        ? p.distractors(_p, _idx + _round * 13)
        : p.distractorsEn(_p, _idx + _round * 17);
    final correct = _isEnToCn ? _p.cn : _p.en;
    final opts = <String>[correct, ...distract];
    // 按固定规则打散，保证每次一致
    final pos = (_idx + _round) % opts.length;
    opts.remove(correct);
    opts.insert(pos, correct);
    return opts;
  }

  String get _correctText => _isEnToCn ? _p.cn : _p.en;

  void _pick(int i) {
    if (_answered) return;
    final opts = _options;
    final ok = opts[i] == _correctText;
    if (ok) {
      SoundFx().correct();
    } else {
      SoundFx().wrong();
    }
    setState(() {
      _picked = i;
      _answered = true;
    });
    // 答对：短暂展示后自动进入下一题
    if (ok) {
      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted && _answered && _picked == i) _next();
      });
    }
  }

  void _next() {
    if (_idx < widget.batch.length - 1) {
      setState(() {
        _idx++;
        _picked = null;
        _answered = false;
      });
    } else {
      _finishRound();
    }
  }

  Future<void> _finishRound() async {
    final p = context.read<EnglishProvider>();
    await p.advanceRound(widget.batch, _round);

    if (_round >= 3) {
      SoundFx().finish();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('本轮 ${widget.batch.length} 个短语已学完')),
        );
      }
      return;
    }

    // 直接进入下一轮，不弹对话框
    if (!mounted) return;
    setState(() {
      _round++;
      _idx = 0;
      _picked = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final opts = _options;
    final total = widget.batch.length;
    // 总进度
    final overall = ((_round - 1) * total + _idx + 1) / (3 * total);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: Text('第 $_round 轮  ${_idx + 1}/$total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: overall.clamp(0.0, 1.0),
            minHeight: 3,
            backgroundColor: AppTheme.line,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 主内容：固定居中，不因答错提示而移动
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          const SizedBox(height: 8),

          // 题干
          Center(
            child: Text(
              _isEnToCn ? _p.en : _p.cn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _isEnToCn ? 28 : 22,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          // 第 1 轮：有例句才显示例句卡
          if (_round == 1 && _p.ex.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_p.ex,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(_p.exCn,
                      style: TextStyle(fontSize: 12.5, color: AppTheme.muted)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),

          // 选项
          ...List.generate(opts.length, (i) {
            final picked = _picked == i;
            final isCorrect = opts[i] == _correctText;
            Color border = AppTheme.line;
            Color? bg;
            if (_answered) {
              if (isCorrect) {
                border = AppTheme.primary;
                bg = AppTheme.primary.withOpacity(0.10);
              } else if (picked) {
                border = Colors.red.shade400;
                bg = Colors.red.withOpacity(0.07);
              }
            } else if (picked) {
              border = AppTheme.primary;
              bg = AppTheme.primary.withOpacity(0.08);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: bg ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _answered ? null : () => _pick(i),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: border,
                          width: picked || (_answered && isCorrect) ? 2 : 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opts[i],
                              style: const TextStyle(fontSize: 16.5)),
                        ),
                        if (_answered && isCorrect)
                          const Icon(Icons.check_circle,
                              size: 18, color: AppTheme.primary),
                        if (_answered && picked && !isCorrect)
                          Icon(Icons.cancel,
                              size: 18, color: Colors.red.shade400),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

                const SizedBox(height: 20),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 答错提示：从底部浮上来，不推挤上方布局
          if (_answered &&
              !(_picked != null && opts[_picked!] == _correctText))
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: RevealIn(
                key: ValueKey('hint_${_p.id}_$_round'),
                offsetY: 24,
                child: _WrongHint(phrase: _p),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _answered
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                      _idx == widget.batch.length - 1
                          ? (_round == 3 ? '完成' : '进入第 ${_round + 1} 轮')
                          : '下一个'),
                ),
              ),
            )
          : null,
    );
  }
}

/// 答错提示浮层：显示正确答案与例句，不参与页面布局
class _WrongHint extends StatelessWidget {
  final Phrase phrase;
  const _WrongHint({required this.phrase});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.18),
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: scheme.tertiary),
                const SizedBox(width: 6),
                Text('正确答案',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.tertiary)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${phrase.en}  ·  ${phrase.cn}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            if (phrase.ex.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(phrase.ex,
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurfaceVariant)),
              Text(phrase.exCn,
                  style: TextStyle(
                      fontSize: 11.5, color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

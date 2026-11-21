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

    // 进入下一轮
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('第 $_round 轮完成'),
        content: Text('接下来是第 ${_round + 1} 轮'
            '${_round + 1 == 3 ? '（中译英）' : '（去掉例句提示）'}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _round++;
                _idx = 0;
                _picked = null;
                _answered = false;
              });
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 提示
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isEnToCn ? '看英文，选中文' : '看中文，选英文',
                style: const TextStyle(fontSize: 11.5, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

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
          // 第 1 轮给提示：有例句显示例句，没例句显示模块
          if (_round == 1) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.line),
              ),
              child: _p.ex.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_p.ex,
                            style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                fontStyle: FontStyle.italic)),
                        const SizedBox(height: 4),
                        Text(_p.exCn,
                            style: TextStyle(
                                fontSize: 12.5, color: AppTheme.muted)),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 15, color: AppTheme.muted),
                        const SizedBox(width: 6),
                        Text('模块 ${_p.module}',
                            style: TextStyle(
                                fontSize: 12.5, color: AppTheme.muted)),
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: bg ?? Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _answered ? null : () => _pick(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: border, width: picked || (_answered && isCorrect) ? 1.6 : 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opts[i],
                              style: const TextStyle(fontSize: 15.5)),
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

          // 只在答错时给解释；答对直接进入下一题
          if (_answered && !(_picked != null && opts[_picked!] == _correctText)) ...[
            const SizedBox(height: 8),
            RevealIn(
              key: ValueKey('hint_${_p.id}_$_round'),
              child: MdCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppTheme.accent),
                        const SizedBox(width: 6),
                        Text('正确答案',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('${_p.en}  —  ${_p.cn}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    if (_p.ex.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_p.ex,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 2),
                      Text(_p.exCn,
                          style: TextStyle(
                              fontSize: 11.5, color: AppTheme.muted)),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animate.dart';
import '../widgets/glass.dart';
import '../utils/sound_fx.dart';

/// 总复习：英文→选中文
/// 答对 → 标记掌握，移出队列
/// 答错 → 显示详情，重新排到队尾
class PhraseReviewScreen extends StatefulWidget {
  const PhraseReviewScreen({super.key});

  @override
  State<PhraseReviewScreen> createState() => _PhraseReviewScreenState();
}

class _PhraseReviewScreenState extends State<PhraseReviewScreen> {
  late List<Phrase> _queue;
  int _idx = 0;
  int? _picked;
  bool _answered = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _totalAtStart = 0;

  @override
  void initState() {
    super.initState();
    final p = context.read<EnglishProvider>();
    _queue = List.of(p.reviewPool);
    _totalAtStart = _queue.length;
  }

  Phrase get _p => _queue[_idx];

  List<String> get _options {
    final p = context.read<EnglishProvider>();
    final distract = p.distractors(_p, _idx + 31);
    final opts = <String>[_p.cn, ...distract];
    final pos = _idx % opts.length;
    opts.remove(_p.cn);
    opts.insert(pos, _p.cn);
    return opts;
  }

  void _pick(int i) {
    if (_answered) return;
    final ok = _options[i] == _p.cn;
    if (ok) {
      SoundFx().correct();
    } else {
      SoundFx().wrong();
    }
    setState(() {
      _picked = i;
      _answered = true;
    });
  }

  Future<void> _next() async {
    final opts = _options;
    final isCorrect = _picked != null && opts[_picked!] == _p.cn;
    final p = context.read<EnglishProvider>();

    if (isCorrect) {
      _correctCount++;
      await p.markMastered(_p.id);
      if (_idx < _queue.length - 1) {
        setState(() {
          _idx++;
          _picked = null;
          _answered = false;
        });
      } else {
        _finish();
      }
    } else {
      _wrongCount++;
      // 重新排到队尾
      setState(() {
        _queue.add(_queue.removeAt(_idx));
        if (_idx >= _queue.length) _idx = 0;
        _picked = null;
        _answered = false;
      });
    }
  }

  void _finish() {
    SoundFx().finish();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('总复习完成'),
        content: Text('本轮 $_totalAtStart 个短语\n'
            '一次答对 $_correctCount 个\n'
            '答错重来 $_wrongCount 次'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opts = _options;
    final isCorrect = _picked != null && opts[_picked!] == _p.cn;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: Text('总复习  ${_idx + 1}/${_queue.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _queue.isEmpty ? 0 : (_idx + 1) / _queue.length,
            minHeight: 3,
            backgroundColor: AppTheme.line,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('看英文，选中文',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.primary)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _p.en,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(opts.length, (i) {
            final picked = _picked == i;
            final correct = opts[i] == _p.cn;
            Color border = AppTheme.line;
            Color? bg;
            if (_answered) {
              if (correct) {
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
                          width: picked || (_answered && correct) ? 2 : 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opts[i],
                              style: const TextStyle(fontSize: 16.5)),
                        ),
                        if (_answered && correct)
                          const Icon(Icons.check_circle,
                              size: 18, color: AppTheme.primary),
                        if (_answered && picked && !correct)
                          Icon(Icons.cancel,
                              size: 18, color: Colors.red.shade400),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          if (_answered && !isCorrect) ...[
            const SizedBox(height: 8),
            RevealIn(
              key: ValueKey('rev_${_p.id}_$_idx'),
              child: MdCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('正确答案',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_p.cn,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('${_p.en}  —  ${_p.cn}',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.muted)),
                    const SizedBox(height: 6),
                    Text('这个词会重新出现，直到答对',
                        style: TextStyle(
                            fontSize: 11.5, color: AppTheme.muted)),
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
                  child: Text(isCorrect ? '下一个' : '重来'),
                ),
              ),
            )
          : null,
    );
  }
}

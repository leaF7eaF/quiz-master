import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animate.dart';
import '../utils/sound_fx.dart';

class PracticeScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;
  const PracticeScreen({super.key, required this.questions, this.title = '练习'});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _index = 0;
  final Map<String, int> _selected = {};
  final Set<String> _submitted = {};
  final Set<String> _revealed = {}; // flash 模式已显示答案
  final Stopwatch _sw = Stopwatch()..start();
  int _correctCount = 0;

  Question get _q => widget.questions[_index];
  int? get _choice => _selected[_q.id];
  bool get _isSubmitted => _submitted.contains(_q.id);
  bool get _isRevealed => _revealed.contains(_q.id);
  bool get _isFlash => _q.type == 'flash';

  static String _letterOf(int i) => String.fromCharCode(65 + i);

  bool _check(Question q, int? choice) {
    if (choice == null) return false;
    return _letterOf(choice) == q.answer.trim().toUpperCase();
  }

  void _submit() async {
    if (_choice == null || _isSubmitted) return;
    final q = _q;
    final ok = _check(q, _choice);
    if (ok) {
      _correctCount++;
      SoundFx().correct();
    } else {
      SoundFx().wrong();
    }
    setState(() => _submitted.add(q.id));
    await context.read<QuizProvider>().answer(q, ok, _sw.elapsedMilliseconds);
    _sw.reset();
    _sw.start();
  }

  /// flash 模式：自评「记住了 / 没记住」后直接进入下一题
  void _submitFlash(bool remembered) async {
    if (_isSubmitted) return;
    final q = _q;
    if (remembered) {
      _correctCount++;
      SoundFx().correct();
    } else {
      SoundFx().wrong();
    }
    setState(() => _submitted.add(q.id));
    await context.read<QuizProvider>().answer(q, remembered, _sw.elapsedMilliseconds);

    // 自评完立刻翻到下一张（最后一题则结束）
    if (!mounted) return;
    if (_index < widget.questions.length - 1) {
      setState(() => _index++);
      _sw.reset();
      _sw.start();
    } else {
      _finish();
    }
  }

  void _reveal() {
    setState(() => _revealed.add(_q.id));
  }

  void _next() {
    if (_index < widget.questions.length - 1) {
      setState(() => _index++);
      _sw.reset();
      _sw.start();
    } else {
      _finish();
    }
  }

  void _finish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('本轮完成'),
        content: Text(
            '共 ${widget.questions.length} 题，掌握 $_correctCount 题\n掌握率 ${(_correctCount / widget.questions.length * 100).toStringAsFixed(0)}%'),
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
    final q = _q;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}  ${_index + 1}/${widget.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_index + 1) / widget.questions.length,
            minHeight: 3,
            backgroundColor: AppTheme.line,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag(q.unit),
              _tag(q.lesson),
              _tag(q.workbook),
              if (!_isFlash)
                ...List.generate(q.difficulty,
                    (_) => const Icon(Icons.star, size: 14, color: AppTheme.accent)),
              if (_isFlash) _tag('速过卡'),
            ],
          ),
          const SizedBox(height: 18),

          // ===== 题干 =====
          if (_isFlash)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(q.stem,
                  style: const TextStyle(
                      fontSize: 19, height: 1.7, fontWeight: FontWeight.w500)),
            )
          else
            Text(q.stem,
                style: const TextStyle(
                    fontSize: 17, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 18),

          // ===== 选项（选择题）=====
          if (!_isFlash) ..._buildOptions(q),

          // ===== 答案区 =====
          if (_isFlash) ...[
            if (_isRevealed)
              RevealIn(
                key: ValueKey('ans_${q.id}'),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('答案',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(q.answer,
                        style: const TextStyle(
                            fontSize: 19,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                    if (q.analysis.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Text(q.analysis,
                          style: const TextStyle(fontSize: 13.5, height: 1.6)),
                    ],
                  ],
                ),
              ),
              ),
          ],

          // ===== 选择题解析 =====
          if (!_isFlash && _isSubmitted) ...[
            const SizedBox(height: 6),
            RevealIn(
              key: ValueKey('ana_${q.id}'),
              offsetY: 6,
              child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('解析',
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('正确答案 ${q.answer}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.primary)),
                  ]),
                  const SizedBox(height: 8),
                  Text(q.analysis,
                      style: const TextStyle(fontSize: 14, height: 1.6)),
                ],
              ),
            ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _isFlash ? _flashActions() : _choiceActions(),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(Question q) {
    return List.generate(q.options.length, (i) {
      final selected = _choice == i;
      final correct = _letterOf(i) == q.answer.trim().toUpperCase();
      Color border = AppTheme.line;
      Color? bg;
      if (_isSubmitted) {
        if (correct) {
          border = AppTheme.primary;
          bg = AppTheme.primary.withOpacity(0.08);
        } else if (selected) {
          border = Colors.red.shade400;
          bg = Colors.red.withOpacity(0.06);
        }
      } else if (selected) {
        border = AppTheme.primary;
        bg = AppTheme.primary.withOpacity(0.08);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PressScale(
          scaleTo: 0.975,
          onTap: _isSubmitted ? null : () => setState(() => _selected[q.id] = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: bg ?? Colors.white,
              border: Border.all(
                  color: border,
                  width: selected || (_isSubmitted && correct) ? 1.6 : 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_letterOf(i)}. ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Expanded(
                    child: Text(q.options[i],
                        style: const TextStyle(fontSize: 15, height: 1.4))),
                if (_isSubmitted && correct)
                  const Icon(Icons.check_circle,
                      size: 18, color: AppTheme.primary),
                if (_isSubmitted && selected && !correct)
                  Icon(Icons.cancel, size: 18, color: Colors.red.shade400),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _choiceActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitted ? null : (_choice == null ? null : _submit),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: AppTheme.primary),
            ),
            child: const Text('提交'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: _isSubmitted ? _next : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: AppTheme.primary,
            ),
            child: Text(_index == widget.questions.length - 1 ? '完成' : '下一题'),
          ),
        ),
      ],
    );
  }

  Widget _flashActions() {
    if (!_isRevealed) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _reveal,
          icon: const Icon(Icons.visibility, size: 20),
          label: const Text('显示答案'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }
    if (!_isSubmitted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _submitFlash(false),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('没记住'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _submitFlash(true),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('记住了'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      );
    }
    // 自评后已自动翻页，这里不会再渲染
    return const SizedBox.shrink();
  }

  Widget _tag(String t) {
    if (t.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(t, style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
    );
  }
}

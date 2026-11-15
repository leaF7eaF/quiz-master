import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;
  const PracticeScreen({super.key, required this.questions, this.title = '练习'});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _index = 0;
  final Map<String, int> _selected = {}; // qid -> 选项下标
  final Set<String> _submitted = {};
  final Stopwatch _sw = Stopwatch()..start();
  int _correctCount = 0;

  Question get _q => widget.questions[_index];
  int? get _choice => _selected[_q.id];
  bool get _isSubmitted => _submitted.contains(_q.id);

  static String _letterOf(int i) => String.fromCharCode(65 + i);

  bool _check(Question q, int? choice) {
    if (choice == null) return false;
    return _letterOf(choice) == q.answer.trim().toUpperCase();
  }

  void _submit() async {
    if (_choice == null || _isSubmitted) return;
    final q = _q;
    final ok = _check(q, _choice);
    if (ok) _correctCount++;
    setState(() => _submitted.add(q.id));
    await context.read<QuizProvider>().answer(q, ok, _sw.elapsedMilliseconds);
    _sw.reset();
    _sw.start();
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
        content: Text('共 ${widget.questions.length} 题，答对 $_correctCount 题\n正确率 ${(_correctCount / widget.questions.length * 100).toStringAsFixed(0)}%'),
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
          // 标签行
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag(q.unit),
              _tag(q.knowledge),
              _tag(q.workbook),
              ...List.generate(q.difficulty, (_) => const Icon(Icons.star, size: 14, color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 14),
          Text(q.stem, style: const TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 18),
          ...List.generate(q.options.length, (i) {
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
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _isSubmitted ? null : () => setState(() => _selected[q.id] = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(
                    color: bg ?? Colors.white,
                    border: Border.all(color: border, width: selected || (_isSubmitted && correct) ? 1.6 : 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_letterOf(i)}. ',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Expanded(child: Text(q.options[i], style: const TextStyle(fontSize: 15, height: 1.4))),
                      if (_isSubmitted && correct)
                        const Icon(Icons.check_circle, size: 18, color: AppTheme.primary),
                      if (_isSubmitted && selected && !correct)
                        Icon(Icons.cancel, size: 18, color: Colors.red.shade400),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_isSubmitted) ...[
            const SizedBox(height: 6),
            Container(
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
                    const Text('解析', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('正确答案 ${q.answer}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                  ]),
                  const SizedBox(height: 8),
                  Text(q.analysis, style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.ink)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
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
          ),
        ),
      ),
    );
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

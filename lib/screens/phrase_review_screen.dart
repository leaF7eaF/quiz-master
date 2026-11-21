import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../widgets/animate.dart';
import '../utils/sound_fx.dart';

class _C {
  static const bg = Color(0xFF0E1A14);
  static const bgTop = Color(0xFF16241C);
  static const card = Color(0x14FFFFFF);
  static const cardBorder = Color(0x1FFFFFFF);
  static const ink = Colors.white;
  static const sub = Color(0x8AFFFFFF);
  static const green = Color(0xFF5FD08A);
  static const red = Color(0xFFE86A6A);
}

/// 总复习：英文 → 选中文，答错重来直到全对
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

  late final EnglishProvider _provider;
  late final DateTime _sessionStart;

  @override
  void initState() {
    super.initState();
    _provider = context.read<EnglishProvider>();
    _sessionStart = DateTime.now();
    _queue = List.of(_provider.reviewPool);
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

  bool get _isCorrect => _picked != null && _options[_picked!] == _p.cn;

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
    final p = context.read<EnglishProvider>();
    if (_isCorrect) {
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
        backgroundColor: const Color(0xFF1E2C24),
        title: const Text('复习完成', style: TextStyle(color: _C.ink)),
        content: Text(
          '本轮 $_totalAtStart 个\n一次答对 $_correctCount 个\n重来 $_wrongCount 次',
          style: const TextStyle(color: _C.sub, height: 1.6),
        ),
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
  void dispose() {
    _provider.addStudySeconds(
        DateTime.now().difference(_sessionStart).inSeconds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _C.ink,
          title: const Text('总复习'),
          elevation: 0,
        ),
        body: const Center(
          child: Text('没有需要复习的短语',
              style: TextStyle(color: _C.sub, fontSize: 14)),
        ),
      );
    }

    final opts = _options;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.bgTop, _C.bg],
              stops: [0.0, 0.45],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                size: 18, color: _C.sub),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('总复习',
                              style: TextStyle(color: _C.sub, fontSize: 13)),
                          const Spacer(),
                          Text('${_idx + 1}/${_queue.length}',
                              style: const TextStyle(
                                  color: _C.sub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (_idx + 1) / _queue.length,
                          minHeight: 2.5,
                          backgroundColor: Colors.white.withOpacity(0.10),
                          color: _C.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _p.en,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _C.ink,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ...List.generate(opts.length, (i) {
                                  final picked = _picked == i;
                                  final correct = opts[i] == _p.cn;
                                  Color bgc = _C.card;
                                  Color bdc = _C.cardBorder;
                                  Color txt = _C.ink;
                                  if (_answered) {
                                    if (correct) {
                                      bgc = _C.green.withOpacity(0.16);
                                      bdc = _C.green.withOpacity(0.55);
                                      txt = _C.green;
                                    } else if (picked) {
                                      bgc = _C.red.withOpacity(0.14);
                                      bdc = _C.red.withOpacity(0.5);
                                      txt = _C.red;
                                    }
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Material(
                                      color: bgc,
                                      borderRadius: BorderRadius.circular(14),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: _answered ? null : () => _pick(i),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 62),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 18),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: bdc, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(opts[i],
                                                    style: TextStyle(
                                                        color: txt,
                                                        fontSize: 16.5,
                                                        height: 1.35)),
                                              ),
                                              if (_answered && correct)
                                                Icon(Icons.check_circle,
                                                    size: 18, color: _C.green),
                                              if (_answered &&
                                                  picked &&
                                                  !correct)
                                                Icon(Icons.cancel,
                                                    size: 18, color: _C.red),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                ),
                if (_answered)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: RevealIn(
                      key: ValueKey('rev_${_p.id}_$_idx'),
                      offsetY: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isCorrect)
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(18, 14, 18, 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2C24),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('正确答案',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: _C.red,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text('${_p.en}  ·  ${_p.cn}',
                                      style: const TextStyle(
                                          color: _C.ink,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('这个词会重新出现，直到答对',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.4))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: _next,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _C.bg,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                              child: Text(_isCorrect ? '下一个' : '重来',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/english_provider.dart';
import '../widgets/animate.dart';
import '../utils/sound_fx.dart';
import '../utils/tts.dart';

/// 深色学习界面配色
class _C {
  static const bg = Color(0xFF0E1A14);
  static const bgTop = Color(0xFF16241C);
  static const card = Color(0x14FFFFFF); // 白 8%
  static const cardBorder = Color(0x1FFFFFFF); // 白 12%
  static const ink = Colors.white;
  static const sub = Color(0x8AFFFFFF); // 白 54%
  static const green = Color(0xFF5FD08A);
  static const red = Color(0xFFE86A6A);
}

/// 新学：一批短语走三轮
class PhraseLearnScreen extends StatefulWidget {
  final List<Phrase> batch;
  const PhraseLearnScreen({super.key, required this.batch});

  @override
  State<PhraseLearnScreen> createState() => _PhraseLearnScreenState();
}

class _PhraseLearnScreenState extends State<PhraseLearnScreen> {
  int _round = 1;
  int _idx = 0;
  int? _picked;
  bool _answered = false;
  String _lastSpoken = '';

  late final EnglishProvider _provider;
  late final DateTime _sessionStart;

  @override
  void initState() {
    super.initState();
    _provider = context.read<EnglishProvider>();
    _sessionStart = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  Phrase get _p => widget.batch[_idx];
  bool get _isEnToCn => _round <= 2;

  List<String> get _options {
    final p = context.read<EnglishProvider>();
    final distract = _isEnToCn
        ? p.distractors(_p, _idx + _round * 13)
        : p.distractorsEn(_p, _idx + _round * 17);
    final correct = _isEnToCn ? _p.cn : _p.en;
    final opts = <String>[correct, ...distract];
    final pos = (_idx + _round) % opts.length;
    opts.remove(correct);
    opts.insert(pos, correct);
    return opts;
  }

  String get _correctText => _isEnToCn ? _p.cn : _p.en;

  bool get _isCorrect => _picked != null && _options[_picked!] == _correctText;

  void _speakCurrent() {
    if (_round != 1) return;
    final key = '${_p.id}_$_round';
    if (_lastSpoken == key) return;
    _lastSpoken = key;
    Tts().speak(_p.en);
  }

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
      WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
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
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _round++;
      _idx = 0;
      _picked = null;
      _answered = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  @override
  void dispose() {
    _provider.addStudySeconds(
        DateTime.now().difference(_sessionStart).inSeconds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opts = _options;
    final total = widget.batch.length;
    final overall = ((_round - 1) * total + _idx + 1) / (3 * total);

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
                // 顶栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: _C.sub),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text('$_round 轮',
                          style: const TextStyle(
                              color: _C.sub, fontSize: 13)),
                      const Spacer(),
                      Text('${_idx + 1}/$total',
                          style: const TextStyle(
                              color: _C.sub,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // 进度线
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: overall.clamp(0.0, 1.0),
                      minHeight: 2.5,
                      backgroundColor: Colors.white.withOpacity(0.10),
                      color: _C.green,
                    ),
                  ),
                ),
                // 主体
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
                            // 例句（第 1 轮）
                            if (_round == 1 && _p.ex.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _C.card,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_p.ex,
                                        style: const TextStyle(
                                            color: _C.sub,
                                            fontSize: 13.5,
                                            height: 1.5,
                                            fontStyle: FontStyle.italic)),
                                    const SizedBox(height: 4),
                                    Text(_p.exCn,
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(0.35),
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            // 题干
                            Text(
                              _isEnToCn ? _p.en : _p.cn,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _C.ink,
                                fontSize: _isEnToCn ? 40 : 30,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => Tts().speak(_p.en),
                              child: Text(
                                _p.phonetic.isNotEmpty ? _p.phonetic : '无音标',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _C.sub,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // 选项
                            ...List.generate(opts.length, (i) {
                              final picked = _picked == i;
                              final correct = opts[i] == _correctText;
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
                                      constraints:
                                          const BoxConstraints(minHeight: 62),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 18),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: bdc, width: 1),
                                        borderRadius: BorderRadius.circular(14),
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
                                          if (_answered && picked && !correct)
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
                // 底部占位，保持布局稳定
              ],
            ),
                // 答错：底部浮层显示正确答案
                if (_answered && !_isCorrect)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: RevealIn(
                      key: ValueKey('hint_${_p.id}_$_round'),
                      offsetY: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
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
                                if (_p.ex.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(_p.ex,
                                      style: const TextStyle(
                                          color: _C.sub,
                                          fontSize: 12.5,
                                          height: 1.4,
                                          fontStyle: FontStyle.italic)),
                                ],
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
                              child: const Text('继续',
                                  style: TextStyle(
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

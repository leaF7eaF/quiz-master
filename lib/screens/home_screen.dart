import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/english_provider.dart';
import '../data/all_questions.dart';
import '../widgets/scenic_background.dart';
import 'phrase_home_screen.dart';
import 'practice_screen.dart';
import 'browse_screen.dart';
import 'wrong_pick_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            const ScenicBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                const Text(
                  '刷题本',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateLabel(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 34),
                _sectionLabel('选择科目'),
                const SizedBox(height: 10),
                ...allSubjects.map((s) => _SubjectRow(meta: s, p: p)),
                const SizedBox(height: 20),
                _sectionLabel('快捷练习'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _QuickBtn(
                      icon: Icons.shuffle,
                      label: '随机 10 题',
                      onTap: () {
                        final qs = List.of(p.currentSubjectQuestions)..shuffle();
                        if (qs.isEmpty) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PracticeScreen(
                                    questions: qs.take(10).toList(),
                                    title: '随机练习')));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickBtn(
                      icon: Icons.error_outline,
                      label: '错题重练',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WrongPickScreen())),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  static String _dateLabel() {
    final d = DateTime.now();
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    return '${d.month} 月 ${d.day} 日 · 周${w[d.weekday - 1]}';
  }

  static Widget _sectionLabel(String t) => Text(
        t,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      );
}

class _SubjectRow extends StatelessWidget {
  final SubjectMeta meta;
  final QuizProvider p;
  const _SubjectRow({required this.meta, required this.p});

  bool get _isEnglish => meta.key == 'english';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DarkGlass(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        radius: 16,
        onTap: () {
          if (_isEnglish) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PhraseHomeScreen()));
          } else {
            p.selectSubject(meta.key);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BrowseScreen()));
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.enLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 3),
                  Text(meta.label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 11.5,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.30), size: 18),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DarkGlass(
      padding: const EdgeInsets.symmetric(vertical: 18),
      radius: 16,
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/english_provider.dart';
import '../data/all_questions.dart';
import '../widgets/scenic_background.dart';
import 'phrase_home_screen.dart';
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
                  'PRACTICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 5,
                    height: 1.1,
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
                // 标题行 + 错题入口
                Row(
                  children: [
                    _sectionLabel('选择科目'),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WrongPickScreen())),
                      child: Row(
                        children: [
                          Icon(Icons.replay,
                              size: 13, color: Colors.white.withOpacity(0.45)),
                          const SizedBox(width: 4),
                          Text('错题重练',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...allSubjects.map((s) => _SubjectRow(meta: s, p: p)),
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

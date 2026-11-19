import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/english_provider.dart';
import 'theme/app_theme.dart';
import 'screens/root_shell.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()..init()),
        ChangeNotifierProvider(create: (_) => EnglishProvider()..init()),
      ],
      child: MaterialApp(
        title: '刷题本',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const RootShell(),
      ),
    );
  }
}

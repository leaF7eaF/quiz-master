import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

/// 存档页：导出/导入答题记录
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _importCtrl = TextEditingController();
  bool _merge = true;

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('存档')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== 导出 =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('导出存档',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('当前共 ${p.totalAnswered} 条答题记录',
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('复制存档到剪贴板'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () async {
                      final text = p.exportArchive();
                      await ClipboardSet.copy(text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '已复制 ${text.length} 字符，粘贴到微信收藏/备忘录保存')));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '复制后建议粘贴到微信「文件传输助手」或手机备忘录长期保存。',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== 导入 =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('导入存档',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Switch(
                      value: _merge,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _merge = v),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_merge ? '合并模式（推荐）' : '替换模式',
                          style: const TextStyle(fontSize: 14)),
                    ),
                  ]),
                  Text(
                    _merge
                        ? '把存档里的记录合并进现有数据，相同记录自动去重。'
                        : '清空当前所有记录，完全用存档内容替代！',
                    style: TextStyle(
                        fontSize: 12,
                        color: _merge ? AppTheme.muted : Colors.red),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _importCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '长按此处粘贴存档内容…',
                      filled: true,
                      fillColor: const Color(0xFF14211A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.line)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('从粘贴内容恢复'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () async {
                      final text = _importCtrl.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请先粘贴存档内容')));
                        return;
                      }
                      if (!_merge) {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('确认替换？'),
                            content: const Text(
                                '当前所有做题记录将被清空，改用存档内容。此操作不可撤销。'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('确认替换')),
                            ],
                          ),
                        );
                        if (ok != true) return;
                      }
                      final msg = await context
                          .read<QuizProvider>()
                          .importArchive(text, merge: _merge);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClipboardSet {
  static Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}

/// 从 JSON 存档兼容读取（备用）
Map<String, dynamic>? tryDecodeJson(String s) {
  try {
    return jsonDecode(s) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

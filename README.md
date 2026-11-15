# 刷题本

九年级文科刷题 App（Flutter）。覆盖 **道德与法治 / 历史 / 语文 / 化学**，内容对齐 **2026 秋启用的统编版新教材**（2022年版课标修订，2027 中考使用版本）。

## 功能

- **四科单选刷题**：题干、四选项、解析，参考佛山中考题型
- **多维度筛选**：按 单元 / 知识点 / 来源 / 全部
- **做题热力图**：像 GitHub 那样一格一天，颜色越深当天做题越多
- **薄弱知识点**：自动统计各知识点正确率，低于 60% 单独列出并排序
- **错题本**：记录最近一次做错的题，可一键重练
- **连续打卡**：今日做题数、连续天数、累计正确率
- **离线可用**：数据全部存在本机，不联网也能做题

## 题库现状

| 科目 | 题量 | 覆盖 |
|---|---|---|
| 道德与法治 | 50 | 四单元（党的领导 / 进入新时代 / 奋进新征程 / 共圆中国梦）|
| 历史 | 46 | 七单元（世界历史：古代亚非→工业革命与马克思主义）|
| 语文 | 24 | 诗歌、文言文、名著、语言运用 |
| 化学 | 25 | 走进化学世界→能源合理利用 |

> 目前是**按课标知识点自编的模拟题**。后续可替换为正版教辅（五三、必刷题等）整理出的题目——把 `lib/data/` 下对应文件按同样格式改掉即可，或整批导入 JSON。

## 如何拿到 APK（GitHub 云构建）

本仓库已配好 `.github/workflows/build-apk.yml`，推到 GitHub 后自动编译：

1. 在 GitHub 新建一个仓库（**Public** 或 Private 都行）
2. 把本目录所有文件推上去（`git init && git add . && git commit -m init && git remote add origin <你的仓库地址> && git push -u origin main`）
3. 打开仓库的 **Actions** 页面，等 `Build APK` 跑完（约 3~6 分钟）
4. 两种下载方式：
   - **Releases**（推荐，免登录）：仓库首页右侧 Releases → `latest` → 下载 `刷题本.apk`
   - **Artifacts**：Actions 运行详情页底部 → `quiz-master-apk`（需登录）

装到手机即可，可离线使用。

## 本地开发

```bash
flutter pub get
flutter run            # 连真机
flutter build apk      # 打包
```

## 目录结构

```
lib/
├── main.dart
├── models/question.dart          # 题目 + 答题记录模型
├── data/
│   ├── all_questions.dart        # 题库汇总 + 科目元信息
│   ├── politics_2026_unit1.dart
│   ├── politics_2026_unit234.dart
│   ├── history_2026_unit14.dart
│   ├── history_2026_unit57.dart
│   ├── chinese_2026.dart
│   └── chemistry_2026.dart
├── providers/quiz_provider.dart  # 状态 + 本地持久化 + 统计
├── theme/app_theme.dart
└── screens/
    ├── root_shell.dart           # 底部导航
    ├── home_screen.dart          # 首页（科目/打卡/快捷）
    ├── browse_screen.dart        # 多维筛选
    ├── practice_screen.dart      # 刷题核心
    ├── heatmap_screen.dart       # 热力图 + 薄弱点
    ├── wrong_screen.dart         # 错题本
    └── stats_screen.dart         # 统计
```

## 添加题目

在 `lib/data/` 里任意文件追加一条：

```dart
{
  "id": "xxx_001",
  "subject": "politics",       // politics / history / chinese / chemistry
  "grade": "九年级",
  "unit": "第一单元 坚持党的全面领导",
  "knowledge": "伟大建党精神",  // 知识点，用于薄弱点分析
  "workbook": "自编",           // 来源：五三 / 必刷题 / 真题 / 自编
  "type": "single",
  "stem": "题干……（ ）",
  "options": ["A选项", "B选项", "C选项", "D选项"],
  "answer": "B",
  "analysis": "解析……",
  "difficulty": 2
}
```

`unit` 和 `knowledge` 保持一致才能正确归类和统计。

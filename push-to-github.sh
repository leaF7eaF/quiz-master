#!/usr/bin/env bash
# 一键把本项目推到 GitHub，并等待云端编译出 APK
# 用法： bash push-to-github.sh https://github.com/<你的用户名>/<仓库名>.git
set -e

if [ -z "$1" ]; then
  echo "用法: bash push-to-github.sh https://github.com/用户名/仓库名.git"
  exit 1
fi

REPO="$1"

echo "== 1/4 初始化仓库 =="
git init -q 2>/dev/null || true
git add -A
git -c user.name="quiz-app" -c user.email="quiz-app@local" commit -q -m "刷题本：九年级文科刷题 App（2026新人教版题库）" || echo "(没有新改动)"

echo "== 2/4 设置远程仓库 =="
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO"

echo "== 3/4 推送到 main =="
git branch -M main
git push -u origin main

echo "== 4/4 完成 =="
echo
echo "接下来："
echo "  1. 打开 $REPO 的 Actions 页面，等 Build APK 跑完（约 3~6 分钟）"
echo "  2. 到仓库 Releases 页面下载「刷题本.apk」直接安装"
echo

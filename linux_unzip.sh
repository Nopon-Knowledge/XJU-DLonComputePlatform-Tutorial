#!/usr/bin/env bash
# 解包 add_wheels_cuda121.zip 到统一的离线仓目录，并把所有 .whl 平铺过去
set -euo pipefail

ZIP="/storage/home/402005/add_wheels_torch241_fix.zip" #带解压文件所在路径
DEST="/storage/home/402005/library/wheelhouse" #解压目标路径
TMP="$(mktemp -d)"

# 1) 前置检查
[ -f "$ZIP" ] || { echo "[ERR] ZIP 不存在: $ZIP" ; exit 2; }
command -v unzip >/dev/null || { echo "[ERR] 未找到 unzip，请先安装或换用 tar/python 解法"; exit 3; }

# 2) 解压到临时目录
mkdir -p "$DEST"
unzip -q -o "$ZIP" -d "$TMP"

# 3) 将所有 .whl 平铺到 DEST（忽略 zip 内部层级）
find "$TMP" -type f -name '*.whl' -exec cp -f {} "$DEST/" \;

# 4) 统计与清理
COUNT=$(find "$DEST" -maxdepth 1 -type f -name '*.whl' | wc -l)
echo "[OK] 已收集 .whl 总数：$COUNT"
rm -rf "$TMP"

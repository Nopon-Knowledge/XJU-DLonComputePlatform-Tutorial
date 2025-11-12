#!/usr/bin/env bash
# 离线安装 einops 到指定 venv
# 可选环境变量覆盖：VENV, PIP, DEST, PKG
#   VENV  默认 $HOME/venvs/test_env
#   PIP   默认 $VENV/bin/pip
#   DEST  默认 $HOME/library/wheelhouse
#   PKG   默认 einops==0.7.0
set -euo pipefail

VENV="${VENV:-$HOME/venvs/unet_env}" #环境路径
PIP="${PIP:-$VENV/bin/pip}"
DEST="${DEST:-$HOME/library/wheelhouse}" #安装包路径
PKG="${PKG:-einops==0.7.0}" #要安装的依赖包

echo "[INFO] venv : $VENV"
echo "[INFO] pip  : $PIP"
echo "[INFO] wheels dir: $DEST"
echo "[INFO] pkg  : $PKG"

# 基础校验
[ -x "$PIP" ] || { echo "[ERR] pip 不存在或不可执行：$PIP"; exit 2; }
[ -d "$DEST" ] || { echo "[ERR] 离线 wheel 目录不存在：$DEST"; exit 3; }

# 安装
"$PIP" install --no-index --find-links "$DEST" "$PKG"

echo "[OK] 安装完成：$PKG"

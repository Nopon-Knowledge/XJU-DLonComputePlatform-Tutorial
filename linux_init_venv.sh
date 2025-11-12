#!/usr/bin/env bash

# 创建并验证一个本地虚拟环境：默认 $HOME/venvs/【您的环境名】

set -euo pipefail

# ========= 可改参数（也支持环境变量或位置参数覆盖） =========
VENV_DIR="${VENV_DIR:-$HOME/venvs/unet_env}" #可以改为你想要的环境路径
PYBASE="${PYBASE:-/storage/software/anaconda3/bin/python}" #选择python来源，该默认路径的python为3.9版本

# 位置参数覆盖
if [[ $# -ge 1 ]]; then VENV_DIR="$1"; fi
if [[ $# -ge 2 ]]; then PYBASE="$2"; fi

echo "[INFO] 目标 venv 目录: $VENV_DIR"
echo "[INFO] 期望基底 Python: $PYBASE"

# ========= 选择可用的基底 Python =========
if [[ ! -x "$PYBASE" ]]; then
  echo "[WARN] 找不到 $PYBASE ，尝试自动探测 python3 ..."
  PYBASE="$(command -v python3 || true)"
fi
if [[ -z "${PYBASE:-}" || ! -x "$PYBASE" ]]; then
  echo "[ERR] 没有可用的 python3，可通过第二个参数或设置 PYBASE 指定路径。"
  exit 2
fi
echo "[INFO] 基底 Python: $PYBASE ($("$PYBASE" -V))"

# ========= 检查 venv 模块 =========
if ! "$PYBASE" -c "import venv" >/dev/null 2>&1; then
  echo "[ERR] 该 Python 缺少内置 venv 模块；请更换 PYBASE（如 /storage/software/anaconda3/bin/python）。"
  exit 3
fi

# ========= 创建 venv =========
mkdir -p "$(dirname "$VENV_DIR")"
"$PYBASE" -m venv "$VENV_DIR"

# ========= 激活并验证 =========
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

echo "[OK] 已激活 venv: $VENV_DIR"
echo "[INFO] which python: $(which python)"
python -V
echo "[INFO] which pip:    $(which pip)"
pip -V

echo "[HINT] 之后要在当前 shell 激活此环境，请运行："
echo "       source \"$VENV_DIR/bin/activate\""

#!/usr/bin/env bash
# 离线修复 venv 中某个包的 METADATA/安装残缺问题
# 环境变量可覆盖：VENV(默认 ~/venvs/test_env) DEST(默认 ~/library/wheelhouse) SPEC(默认 oauthlib==3.3.1)
set -euo pipefail
VENV="${VENV:-$HOME/venvs/test_env}"
DEST="${DEST:-$HOME/library/wheelhouse}"
SPEC="${SPEC:-oauthlib==3.3.1}"

PY="$VENV/bin/python"; PIP="$VENV/bin/pip"
[ -x "$PY" ]  || { echo "[ERR] python not found: $PY"; exit 2; }
[ -x "$PIP" ] || { echo "[ERR] pip not found: $PIP"; exit 3; }
[ -d "$DEST" ]|| { echo "[ERR] wheelhouse not found: $DEST"; exit 4; }

SITE="$($PY - <<'PY'
import site; print([p for p in site.getsitepackages() if 'site-packages' in p][0])
PY
)"

NAME="${SPEC%%==*}"; VER="${SPEC#*==}"
echo "[INFO] VENV=$VENV  SITE=$SITE  SPEC=$SPEC"

# 清理残留
rm -rf "$SITE/${NAME}-"*.dist-info "$SITE/${NAME//-/_}" "$SITE/$NAME" 2>/dev/null || true

# 若有对应 wheel，先解包一份到 site-packages，保证 METADATA
WHEEL="$(ls -1 "$DEST/${NAME}-${VER}"*.whl 2>/dev/null | head -n1 || true)"
if [ -n "$WHEEL" ]; then unzip -o "$WHEEL" -d "$SITE" >/dev/null; else
  echo "[WARN] wheel not found in $DEST for $SPEC — 仍将尝试 pip 离线重装"
fi

# 离线强制重装（不解析依赖）
"$PIP" install --no-index --no-cache-dir --find-links "$DEST" --force-reinstall --no-deps "$SPEC"

# 体检
"$PIP" check || true
"$PY" - <<PY
import importlib, importlib.metadata as md
try:
    m = importlib.import_module("$NAME")
    ver = getattr(m,"__version__","?")
except Exception:
    ver = "import-failed"
print("$NAME:", ver)
print("dist-info present:", any(str(d).startswith("$NAME-$VER") for d in md.distributions()))
PY

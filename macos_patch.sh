#!/usr/bin/env bash
# 为 Linux x86_64 打包 nvidia-curand（以及你 ADD 中的其它包）的离线 whl
set -euo pipefail

# ===== 参数 =====
PYVER=39   # Python 3.9 -> 39；3.10 -> 310；3.11 -> 311
ADD=(
  "packaging==25.0"
  # 需要的话继续往下加："packageA==x.y.z" "packageB==a.b.c"
)

OUT="add_wheels"
mkdir -p "$OUT"

# 升级本机 pip（只影响下载端）
python3 -m pip install -U pip >/dev/null

# 先按 cp$PYVER 过滤下载；若失败，再退到不带 ABI 过滤（适配 nvidia-* 的 py3-none-manylinux 轮子）
if python3 -m pip download -d "$OUT" \
    --only-binary=:all: \
    --platform manylinux2014_x86_64 \
    --python-version "$PYVER" \
    --implementation cp \
    --abi "cp${PYVER}" \
    "${ADD[@]}"; then
  echo "✓ 下载成功（带 cp${PYVER} 过滤）"
else
  echo "… 带 cp${PYVER} 过滤失败，改为不加 ABI 过滤重试"
  python3 -m pip download -d "$OUT" \
    --only-binary=:all: \
    --platform manylinux2014_x86_64 \
    "${ADD[@]}"
fi

# 打包为 zip
zip -rq add_wheels.zip "$OUT"
echo "✅ 补丁包完成：add_wheels.zip"

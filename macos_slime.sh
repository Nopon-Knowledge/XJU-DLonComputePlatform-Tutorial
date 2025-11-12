#!/usr/bin/env bash
# 为 Linux x86_64 打包 torch-2.4.1 需要的两个离线 whl：
#   - nvidia-nccl-cu12==2.20.5   （py3-none-manylinux，勿加 ABI 过滤）
#   - triton==3.0.0              （需 cp39 ABI 过滤）
set -euo pipefail

# ===== 参数 =====
PYVER=39   # Python 3.9 -> 39；3.10 -> 310；3.11 -> 311
OUT="add_wheels"
mkdir -p "$OUT"

# 升级本机 pip（只影响下载端）
python3 -m pip install -U pip >/dev/null

# 工具函数：先 manylinux2014，失败再退 linux_x86_64
dl_plain() {
  local spec="$1"
  if python3 -m pip download -d "$OUT" \
       --only-binary=:all: \
       --platform manylinux2014_x86_64 \
       "$spec" >/dev/null; then
    echo "[OK] $spec  (manylinux2014_x86_64)"
    return 0
  fi
  if python3 -m pip download -d "$OUT" \
       --only-binary=:all: \
       --platform linux_x86_64 \
       "$spec" >/dev/null; then
    echo "[OK] $spec  (linux_x86_64)"
    return 0
  fi
  echo "[MISS] $spec" ; return 1
}

# 工具函数：需要 cp${PYVER} ABI 的包（如 triton）
dl_cp() {
  local spec="$1"
  if python3 -m pip download -d "$OUT" \
       --only-binary=:all: \
       --platform manylinux2014_x86_64 \
       --python-version "$PYVER" --implementation cp --abi "cp${PYVER}" \
       "$spec" >/dev/null; then
    echo "[OK] $spec  (cp${PYVER}, manylinux2014)"
    return 0
  fi
  if python3 -m pip download -d "$OUT" \
       --only-binary=:all: \
       --platform linux_x86_64 \
       --python-version "$PYVER" --implementation cp --abi "cp${PYVER}" \
       "$spec" >/devnull; then
    echo "[OK] $spec  (cp${PYVER}, linux_x86_64)"
    return 0
  fi
  echo "[MISS] $spec" ; return 1
}

# ===== 开始下载 =====
# 1) NCCL（不要加 ABI 过滤）
dl_plain "nvidia-nccl-cu12==2.20.5"

# 2) Triton（需要 cp39 过滤）
dl_cp "triton==3.0.0"

# 打包为 zip
zip -rq add_wheels_torch241_fix.zip "$OUT"
echo "✅ 补丁包完成：add_wheels_torch241_fix.zip（目录：$OUT）"

#!/usr/bin/env bash
# 离线安装 CUDA 组件 + PyTorch 三件套（no-deps）+ 通用依赖
# 生成“库路径注入”脚本并自检
# 可用环境变量：DEST=/path/to/wheelhouse  PIP=/path/to/venv/bin/pip
set -euo pipefail

DEST="${DEST:-$HOME/library/wheelhouse}" # 安装包所在路径
PIP="${PIP:-$HOME/venvs/unet_env/bin/pip}"   # 环境路径，由想要安装到哪个环境决定

[ -x "$PIP" ] || { echo "[ERR] pip 不存在：$PIP"; exit 2; }
[ -d "$DEST" ] || { echo "[ERR] 离线仓不存在：$DEST"; exit 3; }

VENV="$(dirname "$(dirname "$PIP")")"
PY_BIN="$VENV/bin/python"
[ -x "$PY_BIN" ] || { echo "[ERR] python 不存在：$PY_BIN"; exit 4; }

PY_MAJMIN="$("$PY_BIN" -c 'import sys;print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
SITE="$VENV/lib/python${PY_MAJMIN}/site-packages"
echo "[INFO] wheelhouse = $DEST"
echo "[INFO] venv       = $VENV (python $PY_MAJMIN)"
echo "[INFO] site       = $SITE"

# ===== 版本设置（与 torch 2.4.1 + cu121 + cuDNN 9 匹配）=====
TORCH_TRIPLE=( "torch==2.4.1" "torchvision==0.19.1" "torchaudio==2.4.1" )  #改为你需要的pytorch版本
CUDA_PKGS=(
  nvidia-cuda-runtime-cu12==12.1.105
  nvidia-cuda-nvrtc-cu12==12.1.105
  nvidia-cuda-cupti-cu12==12.1.105
  nvidia-cublas-cu12==12.1.3.1
  nvidia-curand-cu12==10.3.2.106
  nvidia-cusolver-cu12==11.4.5.107
  nvidia-cusparse-cu12==12.1.0.106
  nvidia-cufft-cu12==11.0.2.54
  nvidia-nvtx-cu12==12.1.105
  nvidia-nvjitlink-cu12==12.9.86
  nvidia-cudnn-cu12==9.1.0.70
)
# NCCL 给出若干回退版本（离线仓有哪个就装哪个）
NCCL_TRY=( 2.22.3 2.21.5 2.20.5 )

# 常用/纯 Python 依赖（Py3.9 友好）
COMMON_PKGS=(
  numpy==1.26.4
  scipy==1.10.1
  pandas==2.0.3
  matplotlib==3.7.5
  tensorboard==2.15.2
  tqdm==4.66.5
  pyyaml==6.0.1
  opencv-python-headless==4.9.0.80
  filelock==3.12.4
  typing-extensions==4.9.0
  sympy==1.12
  jinja2==3.1.3
  MarkupSafe==2.1.5
  fsspec==2024.2.0
  pillow==10.2.0
  networkx==2.8.8
)

# ===== 0) 清理旧组件，避免依赖牵引 =====
echo "[STEP 0] 卸载旧版 torch/triton/nccl（如有）..."
"$PIP" uninstall -y torch torchvision torchaudio triton nvidia-nccl-cu12 >/dev/null 2>&1 || true

# ===== 1) 安装 CUDA 组件（cu121 套）=====
echo "[STEP 1] 安装 CUDA 组件（cu121 + cuDNN 9 + 常见运行库）..."
"$PIP" install --no-index --no-cache-dir --find-links "$DEST" "${CUDA_PKGS[@]}"

# ===== 1b) 安装 NCCL（多版本尝试）=====
echo "[STEP 1b] 安装 NCCL..."
NCCL_OK=false
for v in "${NCCL_TRY[@]}"; do
  if "$PIP" install --no-index --no-cache-dir --find-links "$DEST" "nvidia-nccl-cu12==$v" >/dev/null 2>&1; then
    echo "         -> nvidia-nccl-cu12==$v OK"
    NCCL_OK=true
    break
  else
    echo "         -> nvidia-nccl-cu12==$v 不在离线仓，尝试下一版..."
  fi
done
$NCCL_OK || { echo "[WARN] 未安装到 nvidia-nccl-cu12（离线仓缺失？）如后续提示 libnccl.so.2 缺失，请补齐 wheel 后再装。"; }

# ===== 2) 安装 PyTorch 三件套（no-deps）=====
echo "[STEP 2] 安装 PyTorch 三件套（no-deps, 2.4.1/cu121）..."
"$PIP" install --no-index --no-cache-dir --find-links "$DEST" --no-deps "${TORCH_TRIPLE[@]}"

# ===== 2b) 安装通用/纯 Python 依赖 =====
echo "[STEP 2b] 安装通用依赖 ..."
"$PIP" install --no-index --no-cache-dir --find-links "$DEST" "${COMMON_PKGS[@]}"

# ===== 3) 生成并加载 CUDA 动态库路径 Hook（运行/作业都需要）=====
echo "[STEP 3] 生成 LD_LIBRARY_PATH 注入脚本..."
HOOK="$VENV/activate_cuda.sh"
cat > "$HOOK" <<'SH'
# 将 venv 内 nvidia/*/lib 注入 LD_LIBRARY_PATH（幂等）
# 使用脚本自身所在目录作为 venv 根目录，避免路径层级错误
set -euo pipefail

VENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYVER="$("$VENV_DIR/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
SITE="$VENV_DIR/lib/python${PYVER}/site-packages"

append_unique () {
  case ":${LD_LIBRARY_PATH:-}:" in
    *":$1:"*) ;;  # 已存在
    *) export LD_LIBRARY_PATH="$1${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";;
  esac
}

for p in cublas cudnn cuda_cupti cuda_nvrtc cuda_runtime curand cusolver cusparse cufft nccl nvjitlink nvtx; do
  d="$SITE/nvidia/$p/lib"
  [ -d "$d" ] && append_unique "$d"
done
SH
chmod +x "$HOOK"

# 立刻对当前 shell 生效（便于自检）
# shellcheck disable=SC1090
source "$HOOK"

# ===== 4) 自检：import torch 并查看 CUDA 可用性 =====
echo "[STEP 4] 自检 import..."
"$PY_BIN" - << 'PY'
import torch
print("torch:", torch.__version__, "cuda build:", torch.version.cuda)
try:
    print("CUDA available:", torch.cuda.is_available())
except Exception as e:
    print("CUDA check error:", e)
PY

echo
echo "[OK] 离线安装完成。"
echo "[HINT] 之后运行/提交作业前，请执行：  source \"$HOOK\""
echo "       或在作业脚本里先： source \"$HOOK\"  再执行 python 训练脚本"

# Windows PowerShell: download Linux x86_64 + CPython3.x wheels (binary only) and zip them.

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# ===== Detect Python =====
$PY = $null; $PY_ARGS = @()
foreach ($cand in @('python','python3')) {
  if (Get-Command $cand -ErrorAction SilentlyContinue) { $PY = $cand; break }
}
if (-not $PY) {
  if (Get-Command 'py' -ErrorAction SilentlyContinue) { $PY = 'py'; $PY_ARGS = @('-3') }
}
if (-not $PY) { throw "Python not found in PATH. Install Python 3.9+ and re-run." }
Write-Host ("Using Python: {0} {1}" -f $PY, ($PY_ARGS -join ' '))

# ===== Basic params =====
$PYVER  = 39            # 目标python版本
$CUDA   = 'cu121'       # 指定cuda版本，如想要cuda12.1，则输入cu121，如想要cpu，则输入cpu
$STAMP  = Get-Date -Format 'yyyyMMddHHmm'
$BUNDLE = "wheelhouse-py$PYVER-$CUDA-$STAMP"

# Index & trusted hosts (help with SSL-intercepting proxies)
$PYPI_INDEX  = 'https://pypi.org/simple'
$TORCH_INDEX = if ($CUDA -eq 'cpu') { 'https://download.pytorch.org/whl/cpu' }
               elseif ($CUDA -eq 'cu118') { 'https://download.pytorch.org/whl/cu118' }
               else { 'https://download.pytorch.org/whl/cu121' }
$TRUSTED = @('--trusted-host','pypi.org','--trusted-host','files.pythonhosted.org','--trusted-host','download.pytorch.org')

# ---- Base deps (PyPI, pinned, Py3.9 compatible) ----
$PKGS_BASE = @(
  'numpy==1.26.4','scipy==1.10.1','pandas==2.0.3',
  'matplotlib==3.7.5','tensorboard==2.15.2',
  'tqdm==4.66.5','pyyaml==6.0.1','opencv-python-headless==4.9.0.80',
  'filelock==3.12.4','typing-extensions==4.9.0','sympy==1.12',
  'jinja2==3.1.3','MarkupSafe==2.1.5','fsspec==2024.2.0',
  'pillow==10.2.0','networkx==2.8.8',
  'importlib-resources==5.13.0','python-dateutil==2.9.0.post0',
  'pytz==2025.2','tzdata==2025.2','kiwisolver==1.4.7',
  'packaging==25.0','pyparsing==3.2.5'
)

# ---- CUDA 运行时依赖 for cu121 (cuDNN9, FFT/Random/NCCL included) ----
$PKGS_CUDA = @()
if ($CUDA -eq 'cu121') {
  $PKGS_CUDA = @(
    'nvidia-cuda-runtime-cu12==12.1.105',
    'nvidia-cuda-nvrtc-cu12==12.1.105',
    'nvidia-cuda-cupti-cu12==12.1.105',
    'nvidia-cublas-cu12==12.1.3.1',
    'nvidia-curand-cu12==10.3.2.106',
    'nvidia-cusolver-cu12==11.4.5.107',
    'nvidia-cusparse-cu12==12.1.0.106',
    'nvidia-cufft-cu12==11.0.2.54',
    'nvidia-nvtx-cu12==12.1.105',
    'nvidia-nvjitlink-cu12==12.9.86',
    'nvidia-cudnn-cu12==9.1.0.70',
    'nvidia-nccl-cu12==2.22.3'
  )
} elseif ($CUDA -eq 'cu118') {
  Write-Warning "You selected cu118. Exact cu11 package versions are not pinned here."
} elseif ($CUDA -ne 'cpu') {
  Write-Warning "Unknown CUDA option: $CUDA (only cu121/cpu are predefined)."
}

# ---- PyTorch triplet (aligned with CUDA) ----
$TORCH_TRIPLE = @('torch==2.4.1','torchvision==0.19.1','torchaudio==2.4.1') #填写所需的pytorch版本

# ===== Run =====
& $PY @PY_ARGS -m pip --version
& $PY @PY_ARGS -m pip install -U pip

New-Item -ItemType Directory $BUNDLE -Force              | Out-Null
New-Item -ItemType Directory "$BUNDLE/wheelhouse" -Force | Out-Null

# 1A) Base deps (manylinux2014_x86_64; pin cp/ABI to Py3.9)
$ARGS_BASE = @(
  '-m','pip','download',
  '-d',"$BUNDLE/wheelhouse",
  '--only-binary',':all:',
  '--platform','manylinux2014_x86_64',
  '--python-version',"$PYVER",
  '--implementation','cp',
  '--abi',"cp$PYVER",
  '--index-url', $PYPI_INDEX
) + $TRUSTED + $PKGS_BASE
Write-Host "Downloading base deps..."
& $PY @PY_ARGS @ARGS_BASE
if ($LASTEXITCODE -ne 0) { throw "pip download (base) failed with exit code $LASTEXITCODE" }

# 1B) CUDA components (allow py3-none-manylinux wheels → do NOT force cp/abi)
if ($PKGS_CUDA.Count -gt 0) {
  $ARGS_CUDA = @(
    '-m','pip','download',
    '-d',"$BUNDLE/wheelhouse",
    '--only-binary',':all:',
    '--platform','manylinux2014_x86_64',
    '--index-url', $PYPI_INDEX
  ) + $TRUSTED + $PKGS_CUDA
  Write-Host "Downloading CUDA components..."
  & $PY @PY_ARGS @ARGS_CUDA
  if ($LASTEXITCODE -ne 0) { throw "pip download (cuda) failed with exit code $LASTEXITCODE" }
}

# 2) Torch triplet (official index; linux_x86_64; --no-deps)
$ARGS_TORCH = @(
  '-m','pip','download',
  '-d',"$BUNDLE/wheelhouse",
  '--only-binary',':all:',
  '--platform','linux_x86_64',
  '--python-version',"$PYVER",
  '--implementation','cp',
  '--abi',"cp$PYVER",
  '--no-deps',
  '--index-url', $TORCH_INDEX,
  '--extra-index-url', $PYPI_INDEX
) + $TRUSTED + $TORCH_TRIPLE
Write-Host "Downloading torch triplet..."
& $PY @PY_ARGS @ARGS_TORCH
if ($LASTEXITCODE -ne 0) { throw "pip download (torch) failed with exit code $LASTEXITCODE" }

# 3) Zip bundle
Compress-Archive -Path $BUNDLE -DestinationPath "$BUNDLE.zip" -Force

# 4) Summary
$whlCount = (Get-ChildItem "$BUNDLE/wheelhouse" -Filter *.whl | Measure-Object).Count
Write-Host ("Done: {0}.zip (collected {1} wheels)" -f $BUNDLE, $whlCount)
Write-Host "Upload the zip to the server, unzip, then install with: pip install --no-index --find-links /path/to/wheelhouse <packages>"

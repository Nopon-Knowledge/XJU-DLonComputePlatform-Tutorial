# 目标 Python 3.9
$PYVER = 39
$ADD = @( #放入你想要的依赖包及版本
  'nvidia-curand-cu12==10.3.2.106'
)
New-Item -ItemType Directory add_wheels -Force | Out-Null

python -m pip download -d add_wheels `
  --only-binary=:all: `
  --platform manylinux2014_x86_64 `
  --python-version $PYVER `
  --implementation cp `
  --abi cp$PYVER `
  @ADD

Compress-Archive -Path add_wheels -DestinationPath add_wheels.zip -Force
Write-Host "✅ 补丁包完成：add_wheels.zip"

# 高算平台使用教程

本项目旨在帮助你在高算平台上运行深度学习项目，包含平台使用教程、环境搭建所需命令脚本、测试环境所用py文件。

同时，个人能力有限，本项目需要大家共同帮助才能更加完善，如果您发现了错误或是有疑问，可以添加微信：18761888658

## 一、远程连接高算平台

### 1、PyCharm SSH连接远程服务器

pycharm下载地址：https://www.jetbrains.com.cn/en-us/pycharm/

首先必须要有pycharm pro订阅，否则无法使用远程开发功能。

第一次使用pycharm可以试用30天pro，如果试用期已过，可以选择去淘宝买激活。

第一步，进入pycharm项目页面后，点击右上角的设置按钮

<img src="images/pycharm_settingicon.png" width="40%" alt="pycharm设置按钮">

左边选择python，进入解释器，点击右方的添加解释器，选择“基于SSH”

<img src="images/pycharm_addinterpreter.png" width="60%" alt="pycharm添加python解释器">

第一次进入，选择新建，主机处填写192.168.222.100，用户名处填写你的账户名，点击下一步

<img src="images/pycharm_ssh_set1.png" width="60%" alt="pycharm添加ssh连接第一步">

输入密码，点击下一步

<img src="images/pycharm_ssh_set2.png" width="60%" alt="pycharm添加ssh连接第二步">

自省页面，等待即可，自省结束“下一步”按钮会亮起，点击下一步

<img src="images/pycharm_ssh_set3.png" width="60%" alt="pycharm添加ssh连接第三步">

远程项目设置页面，我们主要关注红框内的选项

<img src="images/pycharm_ssh_set4.1.png" width="60%" alt="pycharm添加ssh连接第四步">

首先开始设置虚拟环境位置，点击右侧文件夹图标，进入如下页面

<img src="images/pycharm_ssh_hostdir1.png" width="60%" alt="ssh查看远程主机">

进入Storage/Home/【你的账户名】，比如我的账户名是201400920，我就进入201400920文件夹，如下图所示

<img src="images/pycharm_ssh_hostdir2.png" width="45%" alt="ssh查看远程主机">
<img src="images/pycharm_ssh_hostdir3.png" width="45%" alt="ssh查看远程主机">

右键点击账户对应的文件夹，新建环境存放目录，我命名为venvs（即virtual environments），
再右击venvs文件夹，新建一个目录，该目录命名为你想要的环境名，例如我现在想要的是一个用于测试的环境，
我新建一个名为test_env的新目录，然后选择该目录，点击确定后完成。

<img src="images/pycharm_ssh_hostvenvlocation.png" width="45%" alt="ssh查看远程主机 设置venvs路径">

之后我们选择基础解释器路径，点击省略号图标后进入远程主机根目录，依次进入并选择Storage/Software/anaconda3/bin/python3.9

最后，勾选“自动上传项目文件到服务器”，设置同步文件夹路径，之后项目中的内容会被同步到该路径下，依次进入Storage/Home/[你的账户名],
这里建议在自己的用户根目录下新建一个存放项目的文件夹，命名为python_project，再在此文件夹下新建要存放对应项目的项目文件夹。
最终的路径应为Storage/Home/【你的账户名】/python_project/【你的项目名称】

全部设置完之后点击右下角的“创建”按钮，等待其配置完成后，点击pycharm页面左下角的“终端”按钮，点击下拉箭头，选择刚刚设置好的远程终端，

<img src="images/pycharm_terminal1.png" width="70%" alt="选择远程终端">

选择后进入如下终端页面，则SSH连接完成。

<img src="images/pycharm_terminal2.png" width="70%" alt="远程终端连接成功">

### 2、VS Code SSH连接远程服务器

VS Code下载地址：https://code.visualstudio.com/

vs code远程连接首先需要在左方的Extension下载Remote Development插件，如下图所示：

<img src="images/vscode_plugdownload.png" width="50%" alt="vscode下载远程插件">

安装完成后，点击左侧的远程资源管理器，选择远程（隧道/SSH），再点击SSH选项栏右侧的配置按钮，如下图所示：

<img src="images/vscode_sshconfig1.png" width="30%" alt="vscode配置ssh">

点击后，上方会出现如下图所示的配置文件路径，点击进入

<img src="images/vscode_sshconfig2png" width="50%" alt="vscode选择配置文件">

然后会显示如下图一般的配置文件

<img src="images/vscode_sshconfig3.png" width="50%" alt="vscode配置文件">

将下面的ssh配置输入进去
   ```
   Host 【为该ssh连接取一个你想要的名字】
    HostName 【远程服务器的ip地址】
    User 【你的账户名】
    Port 【端口号】
   ```
输入完成后，按ctrl+s或者左侧点击刷新按钮，SSH下会出现刚刚新建的SSH连接，点击箭头连接按钮，上方弹出窗口内选择Linux

<img src="images/vscode_sshconfig4.png" width="30%" alt="vscode开始ssh连接">

进入如下图所示终端：输入yes，再输入你的密码

<img src="images/vscode_terminal1.png" width="70%" alt="vscode终端连接1">

此时点击上方的 终端->新建终端，如果此时终端前缀显示远程服务器账户名@节点，则表示连接成功。

### 3、纯命令行操作（powershell、xshell、terminal等终端均可）

该方法既麻烦也不直观，但会让你看起来像个高手，需要用户非常熟悉linux命令。

windows用户只需要搜索powershell，选择以管理员身份启动，即可开始

macos用户直接启动“terminal”应用即可开始

输入ssh 【你的账户名】@192.168.222.100，输入对应密码，就可以开始操作了。

后续不知道该怎么办？那就老老实实用pycharm或者vscode吧。

## 二、作业调度系统命令

作业调度系统命令请查看：[高算平台作业调度系统命令手册](documents/高算平台作业调度系统命令手册.md)

## 三、环境配置
由于高算平台无法连接外网，因此我们必须使用whl即离线安装包来安装项目所需的依赖环境，这一部分很重要，
也是在该平台运行深度学习项目最麻烦的一个环节，接下来将详细介绍环境配置的流程。

首先，我们需要初始化python基础环境，这里需要用到 [linux_init_venv.sh](linux_init_venv.sh)，该脚本用作linux远程虚拟环境初始化。
只需要注意第8，9行（命令如下），将其修改为你想要的路径。

   ```
   VENV_DIR="${VENV_DIR:-$HOME/venvs/test_env}" #可以改为你想要的环境路径
   PYBASE="${PYBASE:-/storage/software/anaconda3/bin/python}" #选择python来源，该默认路径的python为3.9版本
   ```

之后，在远程终端输入如下命令完成基础环境搭建。
   ```
   bash ~/python_project/test/linux_init_venv.sh
   ```
搭建完成后，可以使用source命令激活。（目前该教程中没有使用conda管理环境，因为该作业系统提交作业时需要指定环境，
所以没有必要再使用conda activate指定环境了）
   ```
   source "~/venvs/test_env/bin/activate"
   ```
激活后，远程终端用户名前会出现环境名，此时可以输入python测试该环境的python版本。

第二步，我们需要使用 [win_makewhl.ps1](win_makewhl.ps1) （macos请使用 [macos_makewhl.sh](macos_makewhl.sh)），
该脚本为windows的powershell脚本，作用是下载深度学习所需的环境依赖，里面已经内置了部分通用依赖，如numpy、matplotlib、tensorboard等等，
默认的pytorch版本为2.4.1+cu121。

只需要关注 18、19、67行，即python版本、cuda版本和pytorch版本，填写完这些之后，那些cuda依赖库应该没人知道要填什么版本，
此时我们需要将该命令交给AI（推荐使用chatgpt），告诉他你要的python版本、cuda版本和pytorch版本，将该脚本内的其它依赖库改为对应版本即可。

   ```
   $PYVER  = 39            # 目标python版本
   $CUDA   = 'cu121'       # 指定cuda版本，如想要cuda12.1，则输入cu121，如想要cpu，则输入cpu
   ...
   ...
   ...
   $TORCH_TRIPLE = @('torch==2.4.1','torchvision==0.19.1','torchaudio==2.4.1') #填写所需的pytorch版本
   ```

更改完成后，使用如下命令运行
   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File .\win_makewhl.ps1
   ```
macos使用
   ```
   bash mmacos_makewhl.sh
   ```
运行成功后，项目内应出现一个压缩包，如下图所示

<img src="images/local_download_zip.png" width="50%" alt="本地下载后的压缩包">

右击该压缩包，选择部署，上传至远程服务器，上传成功后，运行[linux_unzip.sh](linux_unzip.sh)脚本解压缩，
该脚本需要关注5、6行，分别为待解压文件所在路径和解压目标路径。（该操作也可以在web端的图形交互界面完成）
   ```
   ZIP="/storage/home/201400920/wheelhouse-py39-cu121-202511031722.zip" #带解压文件所在路径
   DEST="/storage/home/201400920/library/wheelhouse" #解压目标路径
   ```
解压成功后，运行[linux_installpkgs.sh](linux_installpkgs.sh)脚本来安装我们所需的环境，该脚本主要关注7、8行。
   ```
   DEST="${DEST:-$HOME/library/wheelhouse}" # 安装包所在路径
   PIP="${PIP:-$HOME/venvs/test_env/bin/pip}"   # 环境路径，由想要安装到哪个环境决定
   ```

安装过程往往一次性不会成功，可能会报错显示缺少某些依赖，此时往往只缺失数量较少的依赖，这种少数依赖使用makewhl脚本显然不合适，
我们需要准备一个下载少量依赖的脚本，该脚本为[win_patch.ps1](win_patch.ps1)，主要关注第二行，和第三行开始的数组，
将你所需的依赖包写进该数组， 然后让AI帮忙更改下面的条件命令。
   ```
   $PYVER = 39
   $ADD = @(
       'nvidia-curand-cu12==10.3.2.106'
   )
   ```
少量依赖可以直接使用以下命令安装:
   ```
   PIP="$HOME/venvs/test_env/bin/pip"
   DEST="$HOME/library/wheelhouse"
   "$PIP" install --no-index --find-links "$DEST" einops==0.7.0
   ```

全部安装完成后，运行以下命令
   ```
   pytorch及cuda测试：
   jsub -m gpu01 -q gpu -gpgpu 1 -W 00:01 -o "$HOME/logs/output.%J" -e "$HOME/logs/error.%J" -cwd "$HOME/python_project/test" "$HOME/venvs/test_env/bin/python" test_pytorch.py
   ```
如果最终得到如下图所示的输出，则说明pytorch及cuda配置完成。

<img src="待定" width="50%" alt="测试pytorch的运行结果 图片待补">





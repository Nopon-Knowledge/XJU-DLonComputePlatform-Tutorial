# 高算平台使用教程

本项目旨在帮助你在高算平台上运行深度学习项目，包含平台使用教程、环境搭建所需命令脚本、测试环境所用py文件。

## 一、远程连接高算平台

### 1、PyCharm SSH连接远程服务器

首先必须要有pycharm pro订阅，否则无法使用远程开发功能。

第一次使用pycharm可以试用30天pro，如果试用期已过，可以选择去淘宝买激活。

第一步，进入pycharm项目页面后，点击右上角的设置按钮


<img src="images/pycharm_settingicon.png" width="40%" alt="pycharm设置按钮">

左边选择python，进入解释器，点击右方的添加解释器，选择“基于SSH”

<img src="images/pycharm_addinterpreter.png" width="60%" alt="pycharm添加python解释器">

第一次进入，选择新建，主机处填写192.168.22.100，用户名处填写你的账户名，点击下一步

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

vs code远程连接首先需要在左方的Extension下载Remote Development插件

后续待更新。。。

### 3、纯命令行操作（powershell、xshell、terminal等终端均可）

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
搭建完成后，可以使用source命令激活。（目前该教程中没有使用conda管理环境，日后会更新conda教程）
   ```
   source "~/venvs/test_env/bin/activate"
   ```
激活后，远程终端用户名前会出现环境名，此时可以输入python测试该环境的python版本。

第二步，我们需要使用 [win_makewhl.ps1](win_makewhl.ps1) （如果你是macos，请使用 [macos_makewhl.sh](macos_makewhl.sh)），
该脚本为windows的powershell脚本，作用是下载深度学习所需的环境依赖，里面已经内置了大部分通用依赖，如numpy、matplotlib、tensorboard等等，
默认的pytorch版本为2.4.1+cu121

未完待续。。
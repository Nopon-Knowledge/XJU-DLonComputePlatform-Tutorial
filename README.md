# 高算平台使用教程

本项目旨在帮助你在高算平台上运行深度学习项目，包含平台使用教程、环境搭建所需命令脚本、测试环境所用py文件。

同时，个人能力有限，并且从不同视角出发下都能顺畅理解的教程才是好教程，本项目需要大家共同帮助才能更加完善，如果您发现了错误或是有疑问，可以在issues里讨论或是联系作者。

## 一、远程连接高算平台

### 1、PyCharm SSH连接远程服务器

pycharm下载地址：https://www.jetbrains.com.cn/en-us/pycharm/

pycharm必须为Pro版本，否则无法使用远程开发功能。

第一次使用pycharm可以试用30天pro，如果试用期已过，可以选择去淘宝搜索pycharm买激活。

PyCharm SSH教程请查看：[PyCharm SSH远程连接服务器教程](../documents\pycharm_ssh_tutorial.md)

### 2、VS Code SSH连接远程服务器

VS Code下载地址：https://code.visualstudio.com/

VS Code SSH教程请查看：[VS Code SSH远程连接服务器教程](../documents\vscode_ssh_tutorial.md)

### 3、纯命令行操作（powershell、xshell、terminal等终端均可）

该方法既麻烦也不直观，但会让你看起来像个高手，需要用户非常熟悉linux命令。

windows用户只需要搜索powershell，选择以管理员身份启动，即可开始

macos用户直接启动“terminal”应用即可开始

输入ssh 【你的账户名】@192.168.222.100，输入对应密码，就可以开始操作了。

后续不知道该怎么办？那就老老实实用pycharm或者vscode吧。

## 二、作业调度系统命令

作业调度系统命令请查看：[高算平台作业调度系统命令手册](documents\高算平台作业调度系统命令手册.md)

## 三、环境配置

安装Python流程请查看：[安装Python教程](../documents\如何安装新的python.md)

深度学习项目依赖环境配置流程请查看：[深度学习项目依赖环境配置教程](../documents\深度学习依赖环境配置教程.md)






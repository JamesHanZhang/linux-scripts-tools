
# LinuxAnaconda离线安装快速执行脚本

## 安装
1. 将以下三个文件放置于同一个目录下：
	- anaconda安装程序包，注意程序名需更新到脚本的`CONDA_PACKAGE`参数名；
	  - 例如：`Anaconda3-2023.09-0-Linux-x86_64.sh`
	- anaconda卸载删除程序包`anaconda-clean`，注意程序名需更新到脚本的`CLEAN_PACKAGE`参数名；
	  - 例如：`anaconda-clean-1.1.1-py311h06a4308_0.tar.bz2`
	- 安装及删除执行脚本: `conda_offline_deploy_cmd.sh`
2. 在该目录下右键点击`打开终端`；
3. 如不支持直接打开终端，则`打开终端`后通过`cd`切换路径到执行目录下：
```bash
# 将temp_dir替换成安置脚本的路径
cd temp_dir
```
4. 在终端命令键入如下命令：
```bash
# 打开并学习脚本执行命令教程
bash conda_offline_deploy_cmd.sh -h
# 确认是否有anaconda，如有则跳转至卸载部分，先卸载再进行安装
bash conda_offline_deploy_cmd.sh -c
# 如没有anaconda环境，则执行安装程序
bash conda_offline_deploy_cmd.sh -i
# 执行完成，根据提示退出界面
```

## 卸载
- 如是通过该脚本执行的安装程序，或已经安装了`anaconda-clean`，则选择针对性卸载；
- 如在安装前就有anaconda环境但不确定是否安装`anaconda-clean`，则选择通用卸载；

### 针对性卸载
1. 在脚本`conda_offline_deploy_cmd.sh`所在目录打开终端；
2. 执行如下命令：
```bash
# 确认是否安装环境，如未安装则卸载必然失败
bash conda_offline_deploy_cmd.sh -c
# 如已安装，执行如下命令
bash conda_offline_deploy_cmd.sh -r
# 会问你是否确认安装，请输入YES并回车
# 执行完成，根据提示退出界面
```

### 通用卸载
1. 在脚本`conda_offline_deploy_cmd.sh`所在目录打开终端；
2. 确保同一路径下，需要有`anaconda-clean`的安装包;
3. 执行如下命令
```bash
# 确认是否安装环境，如未安装则卸载必然失败
bash conda_offline_deploy_cmd.sh -c
# 如已安装，执行如下命令
bash conda_offline_deploy_cmd.sh -d
# 会问你是否确认安装，请输入YES并回车
# 执行完成，根据提示退出界面
```
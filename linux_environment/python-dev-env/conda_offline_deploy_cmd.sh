#! /bin/bash
# coding:utf-8
#*********************************************************************************
# CopyRight (C) 2023 JamesHanZhang
# All rights reserved.
# 文件 作用: Linux环境安装Anaconda傻瓜式执行脚本
#           需要预先下载两个安装包, 在安装包放置的路径下执行该脚本
#               1. anaconda安装包
#               2. anaconda-clean安装包
# 当前 版本: V1.0.0
# 作    者: JamesHanZhang
# 完成 日期: 2023/10/26
# 调用脚本方法：
#        chmod 755 脚本名.sh
#        sudo bash 脚本名.sh
#*********************************************************************************
################## 常量 ##################
# 程序名
JOBNAME=`basename $0 .sh`
# 系统日期
DATE=`date +"%Y%m%d"`

# 日志名称（日志路径）
SYS_LOG_FILE=${JOBNAME}.${DATE}.log

# 安装包名
X86_CONDA_PACKAGE=Anaconda3-2023.09-0-Linux-x86_64.sh
ARM64_CONDA_PACKAGE=Anaconda3-2023.09-0-Linux-aarch64.sh
# anaconda-clean安装包名
CLEAN_PACKAGE=anaconda-clean-1.1.1-py311h06a4308_0.tar.bz2

################## 函数 ##################

function makeDir() {
  local checkPath=$1
  if test ! -d ${checkPath}; then
    mkdir -p ${checkPath}
  fi
}

# 计算程序执行时长，加开始时间戳
function getStart() {
  getNow
  start=${now_s}
}
# 计算程序执行时长
function getCostTime() {
  getNow
  local end=${now_s}
  local take=$((${end}-${start}))
  echo -e "${now}: 过程执行时间为 ${take} 秒." >> ${SYS_LOG_FILE}
  echo -e "${now}: 过程执行时间为 ${take} 秒."
}

# 获得当前的时间戳
function getNow() {
  now=`date +"%Y-%m-%d %H:%M:%S"`
  now_s=`date +%s`
}

# 判断程序是否执行成功
function checkSuccess() {
if [ $? -eq 0 ]
then
    local outputMsg=$1
    getNow
    echo -e "${now}: ${outputMsg}: 成功" >> ${SYS_LOG_FILE}
    echo -e "${now}: ${outputMsg}: 成功"
else
    local outputMsg=$1
    getNow
    echo -e "${now}: ${outputMsg}: 失败\n" >> ${SYS_LOG_FILE}
    echo -e "${now}: ${outputMsg}: 失败"
    exit 1
fi
}

function remindUsage() {
  echo -e "脚本使用方法: 在脚本所在目录下,执行该脚本
  示例: sudo bash conda_deploy_cmd.sh -i
  说明:
       sudo bash conda_deploy_cmd.sh -i: 安装Anaconda;
       bash conda_deploy_cmd.sh -c: 确认Anaconda安装情况;
       bash conda_deploy_cmd.sh -r: 卸载Anaconda(针对通过该脚本安装或包含anaconda-clean模块);
       bash conda_deploy_cmd.sh -d: 卸载Anaconda(通用, 需有${CLEAN_PACKAGE}在同一目录下);
       bash conda_deploy_cmd.sh -h: 显示脚本使用说明并退出;"
  exit 1
}

################ 主要执行程序 ################
function installAnaconda() {
  getStart

  local installPackage=$1

  echo -e "安装log信息: ${SYS_LOG_FILE}"
  echo -e "安装log信息: ${SYS_LOG_FILE}" >> ${SYS_LOG_FILE}

  echo -e "安装开始..." >> ${SYS_LOG_FILE}

  # 安装anaconda
  chmod 755 ${installPackage}
  sudo bash ${installPackage} -b -u -p $HOME/anaconda3
  checkSuccess "离线进行Anaconda安装"
  # 如果发现conda找不到指令, 则nano ~/.bashrc在末尾，加上PATH="$HOME/anaconda3/bin:$PATH"
  # echo 'export PATH="'$HOME'/anaconda3/bin:'$PATH'"' >> ~/.bashrc
  # 可以通过 nano ~/.bashrc 查看
  
  source ~/.bashrc  # 刷新bash配置
  checkSuccess "刷新bash配置"
  conda init      # 初始化conda配置
  checkSuccess "初始化conda配置"
  source ~/.bashrc  # 刷新bash配置以使conda配置生效
  checkSuccess "刷新bash配置以使conda配置生效"
  getCostTime

  condaVer=`conda --version`
  checkSuccess "Anaconda环境安装配置版本(${condaVer})"

  chmod 755 ${CLEAN_PACKAGE}
  conda install ${CLEAN_PACKAGE}
  checkSuccess "离线安装卸载程序(为未来卸载作准备)"
  echo -e "Anaconda安装完成，现在您可以退出界面"

  sudo rm -f ${SYS_LOG_FILE}
}

function checkAInstallAnaconda() {
  # 查看Linux系统信息
  arch=`uname -m`

  if [ ${arch} == "x86_64" ]; then
      echo -e "系统为 64-bit (x86_64) 架构, 采用安装包: ${X86_CONDA_PACKAGE}"
      echo -e "系统为 64-bit (x86_64) 架构, 采用安装包: ${X86_CONDA_PACKAGE}" >> ${SYS_LOG_FILE}
      # 在这里执行针对x86_64架构的安装流程
      # 可以安装相应的Anaconda安装包
      installAnaconda ${X86_CONDA_PACKAGE}
  elif [ ${arch} == "aarch64" ]; then
      echo -e "系统为 ARM64 架构, 采用安装包: ${ARM64_CONDA_PACKAGE}" >> ${SYS_LOG_FILE}
      echo -e "系统为 ARM64 架构, 采用安装包: ${ARM64_CONDA_PACKAGE}"
      # 在这里执行针对ARM64架构的安装流程
      # 可以安装相应的Anaconda安装包
      installAnaconda ${ARM64_CONDA_PACKAGE}
  else
      echo -e "无法支持的其他架构: ${arch}"
      echo -e "无法支持的其他架构: ${arch}" >> ${SYS_LOG_FILE}
      # 如果是其他架构，可以给出相应的提示或处理方式
      exit 1
  fi
}

function uninstallAnaconda() {
  conda deactivate
  getStart
  echo -e "卸载开始..." >> ${SYS_LOG_FILE}
  anaconda-clean --yes
  checkSuccess "审核所有待清除的文件"
  sudo rm -rf $HOME/anaconda3
  checkSuccess "删除anaconda文件包"
  sudo rm -rf ~/anaconda3
  checkSuccess "删除anaconda基本配置1"
  sudo rm -rf ~/opt/anaconda3
  checkSuccess "删除anaconda基本配置2"
  getCostTime
  echo -e "Anaconda卸载完成，现在您可以退出界面"
  rm -f ${SYS_LOG_FILE}
}

function specialUninstallAnaconda() {
  echo -e "卸载Anaconda(通用, 需有${CLEAN_PACKAGE}在同一目录下)"
  echo -e "请在卸载前通过-c命令确认您是否已安装成功;如未安装，则不能正常卸载"
  read -p "您确定要卸载Anaconda环境吗?请回答(必须大写) YES: " uninstallCmd
  if [ ${uninstallCmd} == "YES" ]; then
    chmod 755 ${CLEAN_PACKAGE}
    conda install ${CLEAN_PACKAGE}
    checkSuccess "安装卸载程序"
    uninstallAnaconda
  else
    echo -e "卸载命令停止"
    exit 1
  fi
}

function normalUninstallAnaconda() {
  echo -e "卸载Anaconda(针对通过该脚本安装或包含anaconda-clean模块)"
  echo -e "请在卸载前通过-c命令确认您是否已安装成功;如未安装，则不能正常卸载"
  read -p "您确定要卸载Anaconda环境吗?请回答(必须大写) YES: " uninstallCmd
  if [ ${uninstallCmd} == "YES" ]; then
    uninstallAnaconda
  else
    echo -e "卸载命令停止"
    exit 1
  fi
}

function checkAnacondaState() {
  echo -e "如果安装成功，则显示版本；如果安装未成功或者卸载成功，则显示conda 未找到该命令。"
  echo -e "显示结果如下:"
  conda --version
}

################ 执行 #####################



while getopts irdch opt
do
  case ${opt} in
    i)
      checkAInstallAnaconda
      ;;
    r)
      normalUninstallAnaconda
      ;;
    d)
      specialUninstallAnaconda
      ;;
    c)
      checkAnacondaState
      ;;
    h)
      remindUsage
      ;;
    :)
      remindUsage
      ;;
    ?)
      echo -e "无效选项: -${opt}"
      remindUsage
      ;;
  esac
done




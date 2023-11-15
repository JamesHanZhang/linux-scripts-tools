#! /bin/bash
# coding:utf-8
#*********************************************************************************
# CopyRight (C) 2023 JamesHanZhang
# All rights reserved.
# 文件 作用: Linux环境下傻瓜式配置v2ray
#           需要预先下载v2ray安装包
# 当前 版本: V1.0.0
# 作    者: JamesHanZhang
# 完成 日期: 2023/11/09
# 调用脚本方法：
#        chmod 755 脚本名.sh
#        ./脚本名.sh
# 注意:
# 修改ExecStart为: ExecStart=/usr/local/v2ray/v2ray -config /usr/local/v2ray/etc/v2ray/config.json
# sudo bash v2ray_deploy_cmd.sh -m /home/james/Downloads/vtworay
# sudo bash v2ray_deploy_cmd.sh -c /home/james/Downloads/vtworay
# sudo bash v2ray_deploy_cmd.sh -r
# sudo bash v2ray_deploy_cmd.sh -p 10808
# sudo bash v2ray_deploy_cmd.sh -s
#*********************************************************************************
################## 常量 ##################
# 程序名
JOBNAME=`basename $0 .sh`
# 系统日期
DATE=`date +"%Y%m%d"`

# 日志名称（日志路径）
SYS_LOG_FILE=${JOBNAME}.${DATE}.log

# 下载适配版本的v2ray链接: https://github.com/v2ray/v2ray-core/releases/

################## 基本函数 #################
function makeDir() {
  local checkPath=$1
  if test ! -d ${checkPath}; then
    mkdir -p ${checkPath}
  fi
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
  按顺序执行: 先设置v2ray.service
       将ExecStart的值修改为:ExecStart=/usr/local/v2ray/v2ray -config /usr/local/v2ray/etc/v2ray/config.json
  然后执行脚本: -mcs, -r是测试, -h是执行方法提示, 中间可能需要root密码输入
       bash v2ray_deploy_cmd.sh -m: 移动v2ray到指定路径(输入v2ray文件夹所在的路径, 最后无斜杆)
       bash v2ray_deploy_cmd.sh -c: 拷贝config.json到指定路径(输入config.json文件所在路径, 最后无斜杆);测试文件;
       bash v2ray_deploy_cmd.sh -r: 测试执行情况;
       bash v2ray_deploy_cmd.sh -s: 配置环境(防火墙开放端口,配置系统路径v2ray.service);
       bash v2ray_deploy_cmd.sh -h: 显示脚本使用说明并退出;"
  exit 1
}

################### 执行函数 ########################

checkConfigIfCorrect() {
  cd /usr/local/v2ray
  sudo chmod 755 v2ray
  sudo ./v2ray -test -config /usr/local/v2ray/etc/v2ray/config.json
}

runV2ray() {
  # 不执行这个函数, 仅作为提示
  sudo systemctl enable v2ray # 设置开机自启
  sudo systemctl start v2ray # 运行v2ray
  sudo systemctl stop v2ray # 停止v2ray
  sudo systemctl status v2ray # see if it runs
  # ubuntu上述启动命令无效时：
  service v2ray start # 运行v2ray
  service v2ray stop # 停止v2ray
}

while getopts m:c:rp:sd: opt
do
  case ${opt} in
    m)
      # 基本安装
      v2rayPath=${OPTARG}
      makeDir /usr/local/v2ray
      sudo mv "${v2rayPath}/v2ray" /usr/local
      checkSuccess "将v2ray文件夹复制到/usr/local/v2ray目录"
      ;;
    c)
      # config cp
      configPath=${OPTARG}
      makeDir /usr/local/v2ray/etc/v2ray
      cd /usr/local/v2ray/etc/v2ray
      rm -f config.json
      sudo cp "${configPath}/config.json" /usr/local/v2ray/etc/v2ray
      checkSuccess "将config.json复制到/usr/local/v2ray/etc/v2ray文件路径下"
      checkConfigIfCorrect
      checkSuccess "测试配置文件是否配置正确"
      ;;
    r)
      # test run v2ray
      cd /usr/local/v2ray
      chmod 755 v2ray
      sudo ./v2ray --config=./etc/v2ray/config.json
      ;;
    p)
      # 其他配置
      portNum=${OPTARG}
      # ubuntu防火墙放行端口
#      sudo ufw allow ${portNum}
      # ubuntu防火墙放行指定协议的端口
      sudo ufw allow ${portNum}/tcp # 30522为配置文件中的端口号
      # 麒麟系统开放指定端口
#      firewall-cmd --zone=public --add-port=${portNum}/tcp --permanent
      checkSuccess "打开防火墙端口: ${portNum}"
      sudo ufw reload
      checkSuccess "重启防火墙, 使得端口开启生效"
      sudo ufw status # 查看防火墙状态
      ;;
    s)
      # 设置v2ray.service，并拷贝迁移
      # 将ExecStart的值修改为:ExecStart=/usr/local/v2ray/v2ray -config /usr/local/v2ray/etc/v2ray/config.json
      cd /usr/local/v2ray/systemd/system/
      sudo chmod 775 v2ray.service
      sudo cp v2ray.service /lib/systemd/system/
      checkSuccess "添加system文件v2ray.service到/lib/systemd/system路径下"
      cd /lib/systemd/system/
      sudo chmod 775 v2ray.service
      ;;
    d)
      portNum=${OPTARG}
      sudo rm -fr /usr/local/v2ray
      checkSuccess "删除v2ray源文件"
      sudo rm -f /lib/systemd/system/v2ray.service
      checkSuccess "删除system文件v2ray.service"
      # 关闭指定协议的端口
      sudo ufw delete allow ${portNum}/tcp
      checkSuccess "关闭指定TCP协议的端口${portNum}"
      sudo ufw reload
      checkSuccess "重启防火墙, 使得端口关闭生效"
      sudo ufw status # 查看防火墙状态
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


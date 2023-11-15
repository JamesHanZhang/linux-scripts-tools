#! /bin/bash
#*********************************************************************************
# CopyRight (C) 2023 JamesHanZhang
# All rights reserved.
# 文件 作用: oracle环境执行SQL查询语句，导出CSV文件
# 当前 版本: V1.0.0
# 作    者: JamesHanZhang
# 完成 日期: 2023/04/23
# 调用脚本方法：
#        chmod 755 脚本名.sh
#        ./脚本名.sh
#*********************************************************************************
############ 公共参数（需修改）############################
# 导出文件名
outputFile=output.csv

# title的行数，默认为1行：TITLE_ROW_NUM=1
TITLE_ROW_NUM=1

# SQL脚本内关联的参数
queryStartTime="20220101000000"
queryEndTime="20230101000000"

# 本次脚本的主要任务如下
# executeMSG="这里简写脚本主要任务"
executeMSG="查询XXXX数据的时间从${queryStartTime}到${queryEndTime}的数据提取"
########### 公共参数（非必要无需修改）#####################

# 程序名
JOBNAME=`basename $0 .sh`
# 系统日期
DATE=`date +"%Y%m%d"`

# 日志名称（日志路径）
SYS_LOG_FILE=$HOME/log/${JOBNAME}.${DATE}.log

# 导出文件路径
FILEPATH=/home/tempresult

DBUSER=
DBPASSWD=
ORASID=

# 默认前缀
PRE_OUTPUT=

# 拼接导出文件路径
OUTPUT_FILE_PATH=${FILEPATH}/${PRE_OUTPUT}${outputFile}
############# 函数 #####################################

function makeDir() {
  local checkPath=$1
  if test ! -d ${checkPath}; then
    mkdir -p ${checkPath}
  fi
}

# 获得当前的时间戳
function getNow() {
  now=`date +"%Y-%m-%d %H:%M:%S"`
  now_s=`date +%s`
}

# 将sourceFile的内容拷贝到targetFile里
function copyContent() {
  local sourceFile=$1
  local targetFile=$2
  if test -s ${sourceFile}; then
    cat ${sourceFile} >> ${targetFile}
  fi
}

# 判断程序是否执行成功
function checkSuccess() {
if [ $? -eq 0 ]
then
    local outputMsg=$1
    getNow
    echo -e "${now}: ${outputMsg}: Success." >> ${SYS_LOG_FILE}
    echo -e "${now}: ${outputMsg}: Success."
else
    local outputMsg=$1
    getNow
    echo -e "${now}: ${outputMsg}: Failure.\n" >> ${SYS_LOG_FILE}
    echo -e "${now}: ${outputMsg}: Failure."
    if [ $# -eq 2 ];then
          # 针对有导出数据，如报错会自动存入导出文件的情况，需要额外的判断成功与否的函数
          local outputFile=$2
          copyContent ${outputFile} ${SYS_LOG_FILE}
    fi
    exit 1
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
  echo -e "${now}: Execution costs ${take} seconds." >> ${SYS_LOG_FILE}
  echo -e "${now}: Execution costs ${take} seconds."
}

# 计算提取数据数量
function calculateInstancesNumber() {
  # $1:计算的目标文件（含路径）
  local targetFile=$1
  # $2:标题行数，默认为1
  local TITLE_ROW_NUM=$2
  if [ -z ${TITLE_ROW_NUM} ];then
    local TITLE_ROW_NUM=1
  fi
  rowNum=`cat ${targetFile} | wc -l`
  rowNum=$[ ${rowNum} - ${TITLE_ROW_NUM} ]
  getNow
  echo -e "${now}: ${rowNum} instances successfully extracted." >> ${SYS_LOG_FILE}
  echo -e "${now}: ${rowNum} instances successfully extracted."
}

############# 执行程序 #################################

makeDir ${FILEPATH}
getStart
echo -e "${now}: Execution starts: ${executeMSG}\n=====================" >> $SYS_LOG_FILE
echo -e "${now}: Execution starts: ${executeMSG}\n====================="

############# 执行SQL,spool导出CSV文件,请在此修改SQL查询语句 ###############
sqlplus  -S "${DBUSER}/${DBPASSWD}${ORASID}"  <<!
WHENEVER SQLERROR EXIT sql.sqlcode;
set head off;
set long 100000000;
set longc 25500000;
set feedback off;
set wrap off;
set trimout on;
set echo off;
set trimspool on;
set term off;
set linesize 2000;
set pagesize 0;
spool ${OUTPUT_FILE_PATH}
   SELECT 'col1,col2,col3' FROM dual
   UNION All
   SELECT col1 || ',' ||
          col2 || ',' ||
          col3
   FROM test;
spool off;
exit;
!

#############################################################

checkSuccess "Output Data <${OUTPUT_FILE_PATH}>" ${OUTPUT_FILE_PATH}

# 判断时长
getCostTime

# 第二个参数表示title有几行，默认头一行为title
calculateInstancesNumber ${OUTPUT_FILE_PATH} ${TITLE_ROW_NUM}

echo -e "=====================\n${now}: Execution ends: ${executeMSG}\n\n" >> $SYS_LOG_FILE
echo -e "=====================\n${now}: Execution ends: ${executeMSG}\n"
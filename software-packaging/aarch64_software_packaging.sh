#! /bin/bash
# coding:utf-8
#*********************************************************************************
# CopyRight (C) 2023 JamesHanZhang
# All rights reserved.
# 文件 作用: 指导如何在amd64平台(x86_64)打包针对arm64(aarch64)的软件
# 当前 版本: V1.0.0
# 作    者: JamesHanZhang
# 完成 日期: 2023/11/16
# 调用脚本方法：直接在命令行中调用
#*********************************************************************************

############################ ARM64打包软件 ################################
# 更新包列表，运行以下命令以确保你的包列表是最新的：
sudo apt-get update

# 安装ARM64交叉编译工具链： 运行以下命令以安装ARM64的GCC交叉编译工具链：
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# 如果一次安装有些软件没成功，尝试使用以下命令
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu --fix-missing

# 验证安装： 安装完成后，你可以通过运行以下命令来验证是否成功安装：
aarch64-linux-gnu-gcc --version
# 如果成功安装，你应该能够看到ARM64架构的GCC版本信息。


# 设置适当的交叉编译环境。
# 通过设置环境变量，告诉make使用这些工具链进行交叉编译：
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++

# 但是该方法不适用于Pyinstaller, 仅适用于其他的打包软件
# 这里进行代码的打包
# ...

############################ 回到AMD64环境打包软件 ###############################
# 如果你之前设置了CC（C编译器）和CXX（C++编译器）等环境变量，首先清除这些设置。
unset CC
unset CXX

# 确保你的系统默认使用x86_64的本地工具链。通常情况下，这是默认设置，你无需额外设置。如果你之前改变了默认设置，可以通过以下方式将其还原：
export CC=gcc
export CXX=g++

# 运行以下命令来检查CC和CXX是否被正确设置：
# 显示为空则是默认值(amd64), 显示为aarch64-linux-gnu-gxx则为aarch64编译环境
echo $CC
echo $CXX

# 这样，你就清除了之前的交叉编译环境设置，并设置了本地x86_64环境。
# 在此之后，你应该能够在x86_64系统上进行编译和构建，而不会受到之前ARM64环境的影响。
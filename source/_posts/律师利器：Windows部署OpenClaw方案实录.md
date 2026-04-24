---
title: "律师利器：Windows部署OpenClaw方案实录"
date: 2026-04-12
categories: 法律科技
tags: [OpenClaw]
---
律师最贵的是时间，客户最怕的是等。

OpenClaw， 不要工资的助理，24小时在线，凌晨1点还在帮我整理材料。

一觉醒来，发现它做了一堆东西放在电脑桌面上，让我九点打开草稿开始写作。

本文手把手教你在Windows电脑上把它装起来，零基础可跟，最快30分钟。

## 一、OpenClaw是什么

一句话： 一个能本地部署的AI打工仔，7×24在线，不请假，不摸鱼。

<!-- more -->

官网：https://openclaw.ai/

所有 规则明确、可机械执行 的任务都是它的主场——收集信息、收发邮件、整理资料、定时汇报……你定好规则，它替你做。

实战案例库：https://github.com/hesamsheikh/awesome-openclaw-usecases

为什么火？因为市面上大部分AI产品是"聊天玩具"，OpenClaw是 真正能干活的AI 。开源、免费、本地部署，数据不出你的电脑。

📌 OpenClaw拥有文件管理和命令执行权限。指令写不清楚，它可能误删文件或执行错误操作。发送指令前务必考虑风险，及时备份。

## 二、本地部署

### 配置要求

| 项目 | 最低配置 | 推荐配置 |
| --- | --- | --- |
| 系统 | Windows 10 | Windows 10 |
| 内存 | 2GB | 4GB+ |
| CPU | 2核 | 4核+ |
| 硬盘 | 10GB | 40GB+ |

以下为极简安装，不含手机通讯软件配置（可直接用网页UI与OpenClaw互动），最快仅需30分钟。

### 准备清单

1\. **A PI Key** ：硅基流动、阿里云百炼等平台获取  
2\. **网 络** ：确保能访问 https://github.com

### 步骤1：环境安装

**安装 Node.js**

下载地址：https://nodejs.org/zh-cn/download （推荐22版本）

**安装 Git**

部分npm依赖包需要从GitHub拉取源码编译，所以Git必装。

下载地址：https://git-scm.com

**验证安装**

node -v # 应显示 v22.x.x  
npm -v # 应显示版本号  
git --version # 应显示 git version 2.x.x

三个命令都有正常输出，环境就绑好了。

### 步骤2：安装OpenClaw

1\. 开启魔法上网  
2\. 以 **管理员身份** 运行PowerShell

输入以下命令（复制后右键粘贴）：

\# 官方一键安装  
iwr -useb https://openclaw.ai/install.ps1 | iex

顺利的话，你会看到启动界面。

### 步骤3：配置向导

选择模型提供商，填入你的API Key对应的模型。其他选项统统选 **\[ skip for now \]** ，先跑起来再说。

最后选择 **\[Web UI\]** ，浏览器会自动打开 http://127.0.0.1:18789/chat ——这就是你和OpenClaw对话的地方。

### 步骤4：网关启动

如果网页无法连上，运行以下命令（弹出Node防火墙提示时选择"允许"）：

openclaw gateway start

## 三、踩坑记录

部署过程不太可能一路绿灯，以下是我踩过的坑，按出现频率排列。

### 坑1：脚本执行被拒绝

报错： `running scripts is disabled on this system`

**原因：** Windows默认禁止运行未签名脚本。

解法： 管理员PowerShell中执行：

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

输入 `Y` 确认， **关闭PowerShell重新打开** 再安装。还不行就用更强的绕过模式：

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

### 坑2：缺少C++编译工具

报错： `node-gyp failed` / `MSBuild not found` / npm安装中途崩溃

**原因：** OpenClaw部分底层依赖需要本地编译C++代码。

解法：

1\. 下载 Build Tools for Visual Studio  
2\. 安装时勾选 **"C++ build tools"** 工作负载  
3\. 装完后重新运行安装命令

### 坑3：Node.exe路径错误

报错： 路径显示为 `:\Program\node\node.exe` 而非标准路径

**原因：** Node.js安装时环境变量没写对。

解法： 先装Git（会修复部分环境变量），然后彻底关闭PowerShell重新打开：

winget install git.git

### 坑4：openclaw命令找不到

报错： `openclaw is not recognized as a command`

**原因：** npm全局bin目录没加进系统PATH。

解法：

npm prefix -g  
\# 将输出的路径 + \\bin 添加到系统环境变量 PATH 中

### 坑5：Gateway关窗口就停

现象： OpenClaw主体正常，但关了PowerShell窗口服务就断了。

**原因：** 没有以管理员权限把Gateway注册为系统服务。

解法： 必须在 **管理员模式** 下执行：

openclaw gateway install  
openclaw gateway start

## 四、速查表

| 报错现象 | 根本原因 | 解决方案 |
| --- | --- | --- |
| `scripts is disabled` | 执行策略限制 | `Set-ExecutionPolicy RemoteSigned` |
| npm安装中途失败 | 缺少C++编译工具 | 安装VS Build Tools |
| node.exe路径错误 | 环境变量异常 | 先装Git，重启PowerShell |
| `openclaw not found` | PATH未更新 | 手动将npm全局bin加入PATH |
| Gateway关窗口就停 | 未注册为系统服务 | 管理员模式运行 `openclaw gateway install` |

提示： 遇到报错，直接把错误信息粘贴给AI问解决方案。但注意：它给的排查路径不一定最优，要结合自己判断。

注意： 一个问题只采纳一个AI的方案，别同时试多个。否则系统配置互相打架，越改越乱。

写到这里，OpenClaw在飞书上给我发来了消息。

"部署只是开始，连接才是魔法发生的时刻。

· END ·


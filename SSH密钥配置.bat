@echo off
chcp 65001 > nul
echo ==========================================
echo    SSH 免密登录配置脚本
echo ==========================================
echo.

REM 启动 SSH Agent 服务
echo [1/4] 启动 SSH Agent 服务...
net start ssh-agent
if %errorlevel% neq 0 (
    echo 注意：SSH Agent 可能已经在运行
)
echo.

REM 检查密钥文件
echo [2/4] 检查 SSH 密钥文件...
set USERPROFILE_PATH=%USERPROFILE%
if not exist "%USERPROFILE%.ssh\id_ed25519" (
    echo 警告：未找到 SSH 私钥文件！
    echo 位置：%USERPROFILE%.ssh\id_ed25519
    echo.
    echo 请先生成 SSH 密钥：
    echo   ssh-keygen -t ed25519 -C "your_email@example.com"
    echo.
    pause
    exit /b 1
)
echo ✓ 找到私钥文件
echo.

REM 添加密钥到 SSH Agent
echo [3/4] 添加密钥到 SSH Agent...
ssh-add %USERPROFILE%.ssh\id_ed25519
if %errorlevel% neq 0 (
    echo 错误：添加密钥失败！
    pause
    exit /b 1
)
echo ✓ 密钥已添加
echo.

REM 测试连接
echo [4/4] 测试服务器连接...
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@175.178.189.55 "echo '✓ SSH 免密登录成功！'"
if %errorlevel% neq 0 (
    echo 错误：连接测试失败！
    echo 请检查：
    echo 1. 服务器 IP 地址是否正确
    echo 2. SSH 密钥是否已添加到服务器
    pause
    exit /b 1
)
echo ✓ 连接测试成功
echo.

echo ==========================================
echo    配置完成！🎉
echo ==========================================
echo.
echo SSH 免密登录已配置成功！
echo 接下来可以运行部署脚本了。
echo.
pause

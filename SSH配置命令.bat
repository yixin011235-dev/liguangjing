@echo off
chcp 65001 > nul
echo ==========================================
echo    SSH 免密登录配置
echo ==========================================
echo.

echo [步骤 1] 检查 OpenSSH 状态...
powershell -Command "Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'"
echo.

echo [步骤 2] 配置 SSH Agent 服务为自动启动...
sc.exe config ssh-agent start= auto
if %errorlevel% neq 0 (
    echo [警告] 配置失败，尝试其他方法...
)
echo.

echo [步骤 3] 启动 SSH Agent 服务...
net start ssh-agent
if %errorlevel% neq 0 (
    echo [错误] 无法启动 SSH Agent 服务
    echo 请检查是否以管理员身份运行
    pause
    exit /b 1
)
echo.

echo [步骤 4] 验证服务状态...
powershell -Command "Get-Service ssh-agent | Select-Object Name, Status"
echo.

echo [步骤 5] 检查 SSH 密钥文件...
if exist "%USERPROFILE%\.ssh\id_ed25519" (
    echo ✓ 找到 ed25519 密钥
    set KEY_FILE=%USERPROFILE%\.ssh\id_ed25519
) else if exist "%USERPROFILE%\.ssh\id_rsa" (
    echo ✓ 找到 RSA 密钥
    set KEY_FILE=%USERPROFILE%\.ssh\id_rsa
) else (
    echo [错误] 未找到 SSH 私钥文件！
    echo 请先生成 SSH 密钥：
    echo   ssh-keygen -t ed25519 -C "your_email@example.com"
    pause
    exit /b 1
)
echo.

echo [步骤 6] 添加密钥到 SSH Agent...
ssh-add "%KEY_FILE%"
if %errorlevel% neq 0 (
    echo [错误] 添加密钥失败！
    pause
    exit /b 1
)
echo.

echo [步骤 7] 测试服务器连接...
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@175.178.189.55 "echo 'SSH 免密登录成功！'"
if %errorlevel% neq 0 (
    echo [警告] 连接测试失败
    echo 请确保：
    echo 1. 服务器 IP 地址正确：175.178.189.55
    echo 2. 公钥已添加到服务器
    echo.
    echo 添加公钥到服务器的方法：
    echo   type %USERPROFILE%\.ssh\id_ed25519.pub
    echo 复制输出内容，手动添加到服务器
    pause
    exit /b 1
)
echo.

echo ==========================================
echo    配置完成！🎉
echo ==========================================
echo.
echo SSH 免密登录已成功配置！
echo.
echo 现在可以运行部署脚本了：
echo   .\deploy.ps1
echo.
pause

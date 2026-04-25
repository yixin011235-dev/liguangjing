@echo off
chcp 65001 > nul
echo ==========================================
echo    SSH 免密登录一键修复
echo ==========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 建议使用管理员权限运行此脚本
    echo.
)

REM 1. 检查 OpenSSH 安装状态
echo [1/5] 检查 OpenSSH 安装状态...
powershell -Command "Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Select-Object Name, State"
echo.

REM 2. 如果未安装，提示安装
echo [2/5] 检查是否需要安装 OpenSSH...
powershell -Command "$ssh = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'; if ($ssh.State -ne 'Installed') { Write-Host '需要安装 OpenSSH Client'; exit 1 } else { Write-Host 'OpenSSH Client 已安装' }"
if %errorlevel% neq 0 (
    echo.
    echo [错误] OpenSSH Client 未安装！
    echo.
    echo 请在 PowerShell 中以管理员身份运行以下命令安装：
    echo   Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    echo.
    pause
    exit /b 1
)
echo ✓ OpenSSH Client 已安装
echo.

REM 3. 启动 SSH Agent 服务
echo [3/5] 启动 SSH Agent 服务...
sc query ssh-agent >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] SSH Agent 服务未找到！
    echo 请先安装 OpenSSH Client
    pause
    exit /b 1
)

REM 尝试启动服务
net start ssh-agent >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ SSH Agent 服务启动成功
) else (
    echo [警告] SSH Agent 服务启动失败，尝试设置自动启动...
    sc config ssh-agent start= auto
    net start ssh-agent
    if %errorlevel% equ 0 (
        echo ✓ SSH Agent 服务配置并启动成功
    ) else (
        echo [错误] 无法启动 SSH Agent 服务
        echo 请检查：
        echo 1. 是否以管理员身份运行
        echo 2. OpenSSH Client 是否正确安装
        pause
        exit /b 1
    )
)
echo.

REM 4. 检查密钥文件
echo [4/5] 检查 SSH 密钥文件...
set KEY_PATH=%USERPROFILE%\.ssh\id_ed25519
if not exist "%KEY_PATH%" (
    set KEY_PATH=%USERPROFILE%\.ssh\id_rsa
    if not exist "%KEY_PATH%" (
        echo [错误] 未找到 SSH 私钥文件！
        echo.
        echo 请先生成 SSH 密钥：
        echo   ssh-keygen -t ed25519 -C "your_email@example.com"
        echo.
        pause
        exit /b 1
    )
)
echo ✓ 找到私钥文件：%KEY_PATH%
echo.

REM 5. 添加密钥到 SSH Agent
echo [5/5] 添加密钥到 SSH Agent...
ssh-add %KEY_PATH%
if %errorlevel% neq 0 (
    echo [错误] 添加密钥失败！
    pause
    exit /b 1
)
echo ✓ 密钥已添加成功
echo.

REM 测试连接
echo [测试] 测试服务器连接...
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@175.178.189.55 "echo '✓ SSH 免密登录成功！'"
if %errorlevel% neq 0 (
    echo [警告] 连接测试失败
    echo 请确保：
    echo 1. 服务器 IP 地址正确：175.178.189.55
    echo 2. 公钥已添加到服务器
    echo.
    echo 添加公钥到服务器：
    echo   type %USERPROFILE%\.ssh\id_ed25519.pub
    echo 然后复制输出的内容，手动添加到服务器
    pause
    exit /b 1
)
echo.

echo ==========================================
echo    🎉 配置完成！SSH 免密登录已生效
echo ==========================================
echo.
echo 现在可以运行部署脚本了：
echo   .\deploy.ps1
echo.
pause

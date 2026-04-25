@echo off
chcp 65001 > nul
echo ==========================================
echo    SSH 公钥上传到服务器
echo ==========================================
echo.

REM 显示本机公钥
echo [步骤 1] 显示本机公钥：
echo.
type %USERPROFILE%\.ssh\id_ed25519.pub
echo.
echo.

REM 复制上面的公钥内容，然后上传到服务器
echo [步骤 2] 上传公钥到服务器：
echo.
echo 请手动复制上面的公钥内容（全选，Ctrl+C）
echo 然后在服务器上执行以下命令添加公钥：
echo.
echo 1. 连接到服务器：
echo    ssh root@175.178.189.55
echo.
echo 2. 在服务器上创建 SSH 目录：
echo    mkdir -p ~/.ssh
echo.
echo 3. 添加公钥（将下面的 XXX 替换为你的公钥）：
echo    echo "这里粘贴你的公钥" ^>^> ~/.ssh/authorized_keys
echo.
echo 4. 设置权限：
echo    chmod 700 ~/.ssh
echo    chmod 600 ~/.ssh/authorized_keys
echo.
echo 5. 退出服务器：
echo    exit
echo.
echo.

REM 测试连接
echo [步骤 3] 测试免密登录：
echo.
ssh root@175.178.189.55 "echo 'SSH 免密登录成功！'"
if %errorlevel% equ 0 (
    echo.
    echo ✓ 免密登录配置成功！
) else (
    echo.
    echo ✗ 免密登录失败，请检查公钥是否正确添加
)
echo.
pause

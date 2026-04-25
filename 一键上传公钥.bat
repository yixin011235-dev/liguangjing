@echo off
chcp 65001 > nul
echo ==========================================
echo    SSH 公钥一键上传脚本
echo ==========================================
echo.

REM 显示你的公钥
echo [1/3] 你的 SSH 公钥：
echo.
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiGxl05gas1WsyFQFp3XAXz1OVjU3SlxC6CFL2EcU8Y my-laptop
echo.

REM 复制公钥到临时文件
echo | set /p="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiGxl05gas1WsyFQFp3XAXz1OVjU3SlxC6CFL2EcU8Y my-laptop" > %TEMP%\pubkey.txt

REM 上传到服务器
echo [2/3] 上传公钥到服务器（需要输入服务器密码）...
scp %TEMP%\pubkey.txt root@175.178.189.55:/tmp/pubkey.txt
if %errorlevel% neq 0 (
    echo [错误] 上传失败！
    pause
    exit /b 1
)
echo ✓ 公钥上传成功
echo.

REM 在服务器上配置公钥
echo [3/3] 在服务器上配置公钥（需要输入服务器密码）...
ssh root@175.178.189.55 "mkdir -p ~/.ssh && cat /tmp/pubkey.txt >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && rm /tmp/pubkey.txt && echo '公钥配置成功！'"
if %errorlevel% neq 0 (
    echo [错误] 配置失败！
    pause
    exit /b 1
)
echo.

REM 测试免密登录
echo [测试] 测试免密登录...
ssh -o StrictHostKeyChecking=no root@175.178.189.55 "echo 'SSH 免密登录成功！🎉'"
if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo    配置完成！SSH 免密登录已生效！
    echo ==========================================
    echo.
    echo 现在可以运行部署脚本了：
    echo   .\deploy.ps1
    echo.
) else (
    echo.
    echo [错误] 测试失败，请检查配置
    echo.
)
echo.
pause

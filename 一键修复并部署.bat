@echo off
chcp 65001 > nul
echo ==========================================
echo    修复权限并部署博客
echo ==========================================
echo.

echo [1/2] 修复服务器权限（需要输入密码）...
ssh ubuntu@175.178.189.55 "sudo chown -R ubuntu:ubuntu /var/www/hexo && sudo chmod -R 755 /var/www/hexo && echo '权限修复成功！'"
if %errorlevel% neq 0 (
    echo [错误] 权限修复失败！
    echo 请确保 ubuntu 用户有 sudo 权限
    pause
    exit /b 1
)
echo.

echo [2/2] 开始部署博客...
echo.

REM 切换到 PowerShell 执行部署
powershell.exe -ExecutionPolicy Bypass -Command "& {Set-Location 'd:\my-blog'; .\deploy-ubuntu.ps1}"

echo.
echo ==========================================
echo    操作完成
echo ==========================================
echo.
pause

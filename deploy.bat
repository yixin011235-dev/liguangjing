@echo off
chcp 65001 > nul
REM ===========================================
REM Hexo 博客自动部署脚本 (Windows版)
REM 适用于腾讯云服务器
REM ===========================================

echo ==========================================
echo    Hexo 博客自动部署脚本
echo ==========================================

REM 配置区域 - 请根据实际情况修改
set SERVER_IP=175.178.189.55
set SERVER_USER=root
set SERVER_PATH=/var/www/hexo
set SSH_PORT=22

REM 1. 清理并生成静态文件
echo.
echo [1/4] 清理旧文件并生成博客...
call npx hexo clean
call npx hexo generate

if %errorlevel% neq 0 (
    echo 错误：博客生成失败！
    pause
    exit /b 1
)

echo ✓ 博客生成成功

REM 2. 同步文件到服务器
echo.
echo [2/4] 同步文件到服务器 (%SERVER_IP%)...

REM 使用 rsync 同步文件
rsync -avz --delete ^
    -e "ssh -p %SSH_PORT%" ^
    --exclude '.DS_Store' ^
    --exclude 'node_modules' ^
    .\public\ ^
    %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%/

if %errorlevel% neq 0 (
    echo 错误：文件同步失败！
    pause
    exit /b 1
)

echo ✓ 文件同步成功

REM 3. 在服务器上设置正确的权限
echo.
echo [3/4] 设置服务器文件权限...

ssh -p %SSH_PORT% %SERVER_USER%@%SERVER_IP% "chmod -R 755 /var/www/hexo && find /var/www/hexo -type f -exec chmod 644 {} \; && echo 权限设置完成"

if %errorlevel% neq 0 (
    echo 错误：权限设置失败！
    pause
    exit /b 1
)

echo ✓ 权限设置成功

REM 4. 重启 Nginx
echo.
echo [4/4] 重启 Nginx 服务...

ssh -p %SSH_PORT% %SERVER_USER%@%SERVER_IP% "systemctl restart nginx"

if %errorlevel% neq 0 (
    echo 错误：Nginx 重启失败！
    pause
    exit /b 1
)

echo ✓ Nginx 重启成功

REM 完成
echo.
echo ==========================================
echo    部署完成！🎉
echo ==========================================
echo.
echo 访问你的网站：https://liguangjing.top
echo.

pause

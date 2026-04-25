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
echo [1/5] 清理旧文件并生成博客...
call npx hexo clean
call npx hexo generate

if %errorlevel% neq 0 (
    echo 错误：博客生成失败！
    pause
    exit /b 1
)

echo ✓ 博客生成成功

REM 2. 清空服务器上的旧文件
echo.
echo [2/5] 清空服务器旧文件...
ssh -p %SSH_PORT% %SERVER_USER%@%SERVER_IP% "rm -rf /var/www/hexo/* && echo 服务器旧文件已清空"

if %errorlevel% neq 0 (
    echo 警告：清空服务器文件失败，继续尝试复制...
)

echo ✓ 服务器准备就绪

REM 3. 复制文件到服务器（使用 scp）
echo.
echo [3/5] 复制文件到服务器 (%SERVER_IP%)...

REM 使用 scp 递归复制文件
scp -P %SSH_PORT% -r .\public\* %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%/

if %errorlevel% neq 0 (
    echo 错误：文件复制失败！
    pause
    exit /b 1
)

echo ✓ 文件复制成功

REM 4. 设置正确的权限
echo.
echo [4/5] 设置服务器文件权限...

ssh -p %SSH_PORT% %SERVER_USER%@%SERVER_IP% "chmod -R 755 /var/www/hexo && find /var/www/hexo -type f -exec chmod 644 {} \; && echo 权限设置完成"

if %errorlevel% neq 0 (
    echo 错误：权限设置失败！
    pause
    exit /b 1
)

echo ✓ 权限设置成功

REM 5. 重启 Nginx
echo.
echo [5/5] 重启 Nginx 服务...

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

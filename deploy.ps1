# Hexo Blog Deployment Script (PowerShell Version)
# 自动部署博客到腾讯云服务器

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Hexo 博客自动部署脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Configuration
$SERVER_IP = "175.178.189.55"
$SERVER_USER = "root"
$SERVER_PATH = "/var/www/hexo"
$SSH_PORT = "22"

# Step 1: Clean and generate static site
Write-Host ""
Write-Host "[1/5] Cleaning old files and generating blog..." -ForegroundColor Yellow
Set-Location $PSScriptRoot
npx hexo clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Blog generation failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
npx hexo generate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Blog generation failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Blog generated successfully" -ForegroundColor Green

# Step 2: Clean old files on server
Write-Host ""
Write-Host "[2/5] Cleaning old files on server..." -ForegroundColor Yellow
ssh -p $SSH_PORT $SERVER_USER@$SERVER_IP "rm -rf /var/www/hexo/* && echo 'Server old files cleaned'"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Server ready" -ForegroundColor Green
} else {
    Write-Host "Warning: Failed to clean server files, continuing..." -ForegroundColor Yellow
}

# Step 3: Copy files to server using scp
Write-Host ""
Write-Host "[3/5] Copying files to server ($SERVER_IP)..." -ForegroundColor Yellow
scp -P $SSH_PORT -r .\public\* $SERVER_USER@$SERVER_IP`:$SERVER_PATH/
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: File copy failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Files copied successfully" -ForegroundColor Green

# Step 4: Set correct permissions
Write-Host ""
Write-Host "[4/5] Setting server file permissions..." -ForegroundColor Yellow
ssh -p $SSH_PORT $SERVER_USER@$SERVER_IP "chmod -R 755 /var/www/hexo && find /var/www/hexo -type f -exec chmod 644 {} \; && echo 'Permissions set'"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Permission setting failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Permissions set successfully" -ForegroundColor Green

# Step 5: Restart Nginx
Write-Host ""
Write-Host "[5/5] Restarting Nginx service..." -ForegroundColor Yellow
ssh -p $SSH_PORT $SERVER_USER@$SERVER_IP "systemctl restart nginx"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Nginx restart failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Nginx restarted successfully" -ForegroundColor Green

# Complete
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Deployment Complete! " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Visit your website: https://liguangjing.top" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to exit" -ForegroundColor Gray
Read-Host

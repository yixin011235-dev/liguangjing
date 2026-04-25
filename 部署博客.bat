# Hexo Blog Quick Deploy
# 快速部署脚本 - 一键完成

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Hexo 博客快速部署" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Set-Location $PSScriptRoot

Write-Host "[1/3] 生成静态网站..." -ForegroundColor Yellow
npx hexo clean
npx hexo generate
Write-Host "完成" -ForegroundColor Green

Write-Host "[2/3] 部署到服务器..." -ForegroundColor Yellow
ssh ubuntu@175.178.189.55 "rm -rf /var/www/hexo/* && echo '清理完成'"
scp -P 22 -r .\public\* ubuntu@175.178.189.55:/var/www/hexo/
ssh ubuntu@175.178.189.55 "sudo chmod -R 755 /var/www/hexo && sudo systemctl restart nginx"
Write-Host "完成" -ForegroundColor Green

Write-Host "[3/3] 推送到GitHub..." -ForegroundColor Yellow
git add .
git commit -m "更新博客 $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main
Write-Host "完成" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "   部署完成！访问 https://liguangjing.top" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# ===========================================
# 服务器一键初始化脚本 (PowerShell版)
# ===========================================

Write-Host "==========================================" -ForegroundColor Green
Write-Host "   服务器一键初始化" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# 配置
$ServerIP = "175.178.189.55"
$ServerUser = "root"
$Domain = "liguangjing.top"

Write-Host "[1/4] 上传证书到服务器..." -ForegroundColor Yellow
Write-Host "提示：如果提示 Are you sure，输入: yes"
Write-Host ""

scp D:\my-blog\liguangjing.top_nginx\liguangjing.top.key "$ServerUser@$ServerIP`:/tmp/liguangjing.top.key"
scp D:\my-blog\liguangjing.top_nginx\liguangjing.top_bundle.crt "$ServerUser@$ServerIP`:/tmp/liguangjing.top_bundle.crt"

Write-Host ""
Write-Host "[2/4] 创建目录并移动证书..." -ForegroundColor Yellow

$cmd2 = @"
mkdir -p /var/www/hexo /etc/nginx/ssl /etc/nginx/sites-available /etc/nginx/sites-enabled
mv /tmp/liguangjing.top.key /etc/nginx/ssl/
mv /tmp/liguangjing.top_bundle.crt /etc/nginx/ssl/
chmod 600 /etc/nginx/ssl/liguangjing.top.key
echo "目录和证书配置完成"
"@

ssh $ServerUser@$ServerIP $cmd2

Write-Host ""
Write-Host "[3/4] 创建 Nginx 配置..." -ForegroundColor Yellow

$nginxConfig = @"
server {
    listen 80;
    server_name $Domain www.$Domain;
    return 301 https://`$server_name`$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $Domain www.$Domain;
    ssl_certificate /etc/nginx/ssl/$Domain`_bundle.crt;
    ssl_certificate_key /etc/nginx/ssl/$Domain.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    root /var/www/hexo;
    index index.html;
    charset utf-8;
    location / {
        try_files `$uri `$uri/ =404;
    }
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}
"@

ssh $ServerUser@$ServerIP "cat > /etc/nginx/sites-available/$Domain << 'NGINXEOF'"
ssh $ServerUser@$ServerIP $nginxConfig
ssh $ServerUser@$ServerIP "NGINXEOF"

Write-Host ""
Write-Host "[4/4] 启用网站并重启 Nginx..." -ForegroundColor Yellow

$cmd4 = @"
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/$Domain /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
systemctl status nginx | head -3
"@

ssh $ServerUser@$ServerIP $cmd4

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "   ✅ 初始化完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：上传博客文件" -ForegroundColor Cyan
Write-Host "运行: rsync -avz --delete -e `"ssh -p 22`" D:\my-blog\public\ $ServerUser@$ServerIP`:/var/www/hexo/" -ForegroundColor Cyan
Write-Host ""

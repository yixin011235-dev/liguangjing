@echo off
chcp 65001 > nul
echo ==========================================
echo    服务器一键初始化
echo ==========================================
echo.

echo [1/4] 上传证书到服务器...
scp D:\my-blog\liguangjing.top_nginx\liguangjing.top.key root@175.178.189.55:/tmp/liguangjing.top.key
scp D:\my-blog\liguangjing.top_nginx\liguangjing.top_bundle.crt root@175.178.189.55:/tmp/liguangjing.top_bundle.crt
echo.

echo [2/4] 配置服务器（请耐心等待）...
echo 提示：如果提示 Are you sure you want to continue connecting，输入: yes
echo.

ssh root@175.178.189.55 "mkdir -p /var/www/hexo /etc/nginx/ssl /etc/nginx/sites-available /etc/nginx/sites-enabled && mv /tmp/liguangjing.top.key /etc/nginx/ssl/ && mv /tmp/liguangjing.top_bundle.crt /etc/nginx/ssl/ && chmod 600 /etc/nginx/ssl/liguangjing.top.key"

echo.
echo [3/4] 创建 Nginx 配置...
ssh root@175.178.189.55 "cat > /etc/nginx/sites-available/liguangjing.top << 'NGINXCONFIG'
server {
    listen 80;
    server_name liguangjing.top www.liguangjing.top;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name liguangjing.top www.liguangjing.top;
    ssl_certificate /etc/nginx/ssl/liguangjing.top_bundle.crt;
    ssl_certificate_key /etc/nginx/ssl/liguangjing.top.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    root /var/www/hexo;
    index index.html;
    charset utf-8;
    location / {
        try_files \$uri \$uri/ =404;
    }
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}
NGINXCONFIG"

echo.
echo [4/4] 启用网站并重启 Nginx...
ssh root@175.178.189.55 "rm -f /etc/nginx/sites-enabled/default && ln -sf /etc/nginx/sites-available/liguangjing.top /etc/nginx/sites-enabled/ && nginx -t && systemctl restart nginx && systemctl status nginx | head -3"

echo.
echo ==========================================
echo    ✅ 初始化完成！
echo ==========================================
echo.
echo 下一步：上传博客文件
echo 运行: rsync -avz --delete -e "ssh -p 22" D:\my-blog\public\ root@175.178.189.55:/var/www/hexo\
echo.
pause

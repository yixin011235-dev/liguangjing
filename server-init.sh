#!/bin/bash

# ===========================================
# 服务器一键初始化脚本（完全自动化）
# 运行一次即可完成所有配置
# ===========================================

# 配置区域 - 根据你的信息自动设置
DOMAIN="liguangjing.top"
SERVER_IP="175.178.189.55"
SERVER_USER="root"
SSH_PORT="22"

echo "=========================================="
echo "   服务器一键初始化"
echo "=========================================="
echo "域名: $DOMAIN"
echo "服务器: $SERVER_IP"
echo ""

# 1. 上传证书文件
echo "[1/4] 上传证书到服务器..."
scp -P $SSH_PORT /d/my-blog/liguangjing.top_nginx/liguangjing.top.key $SERVER_USER@$SERVER_IP:/tmp/liguangjing.top.key
scp -P $SSH_PORT /d/my-blog/liguangjing.top_nginx/liguangjing.top_bundle.crt $SERVER_USER@$SERVER_IP:/tmp/liguangjing.top_bundle.crt
echo "✓ 证书上传成功"
echo ""

# 2. 在服务器上一键配置
echo "[2/4] 一键配置服务器（大约需要30秒）..."
ssh -p $SSH_PORT $SERVER_USER@$SERVER_IP << 'ENDSSH'

echo "[2.1] 创建目录..."
mkdir -p /var/www/hexo
mkdir -p /etc/nginx/ssl
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

echo "[2.2] 移动证书文件..."
mv /tmp/liguangjing.top.key /etc/nginx/ssl/
mv /tmp/liguangjing.top_bundle.crt /etc/nginx/ssl/
chmod 600 /etc/nginx/ssl/liguangjing.top.key

echo "[2.3] 创建 Nginx 配置..."
cat > /etc/nginx/sites-available/liguangjing.top << 'NGINXCONFIG'
server {
    listen 80;
    server_name liguangjing.top www.liguangjing.top;
    return 301 https://$server_name$request_uri;
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
        try_files $uri $uri/ =404;
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}

NGINXCONFIG

echo "✓ Nginx 配置已创建"

echo "[2.4] 启用网站..."
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/liguangjing.top /etc/nginx/sites-enabled/

echo "[2.5] 测试配置..."
nginx -t

echo "[2.6] 重启 Nginx..."
systemctl restart nginx

echo "[2.7] 验证服务状态..."
systemctl status nginx | head -3

echo ""
echo "✓✓✓ 服务器初始化完成！✓✓✓"
echo ""
echo "现在可以上传博客文件了！"
echo "运行: rsync -avz --delete -e 'ssh -p 22' ./public/ root@175.178.189.55:/var/www/hexo/"

ENDSSH

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "   ✅ 初始化成功！"
    echo "=========================================="
    echo ""
    echo "下一步操作："
    echo "1. 运行以下命令上传博客文件："
    echo ""
    echo "   rsync -avz --delete -e \"ssh -p $SSH_PORT\" ./public/ $SERVER_USER@$SERVER_IP:/var/www/hexo/"
    echo ""
    echo "2. 访问 https://liguangjing.top 验证"
    echo ""
else
    echo "错误：服务器配置失败！"
    echo "请检查 SSH 连接是否正常"
    exit 1
fi

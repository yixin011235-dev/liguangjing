#!/bin/bash

# ===========================================
# Hexo 博客自动部署脚本
# 适用于腾讯云服务器
# ===========================================

# 配置区域 - 请根据实际情况修改
SERVER_IP="175.178.189.55"
SERVER_USER="root"
SERVER_PATH="/var/www/hexo"
SSH_PORT="22"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Hexo 博客自动部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. 清理并生成静态文件
echo -e "\n${YELLOW}[1/4] 清理旧文件并生成博客...${NC}"
cd "$(dirname "$0")"
hexo clean
hexo generate

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：博客生成失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 博客生成成功${NC}"

# 2. 同步文件到服务器
echo -e "\n${YELLOW}[2/4] 同步文件到服务器 (${SERVER_IP})...${NC}"

# 使用 rsync 同步文件
rsync -avz --delete \
    -e "ssh -p ${SSH_PORT}" \
    --exclude '.DS_Store' \
    --exclude 'node_modules' \
    ./public/ \
    ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：文件同步失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 文件同步成功${NC}"

# 3. 在服务器上设置正确的权限
echo -e "\n${YELLOW}[3/4] 设置服务器文件权限...${NC}"

ssh -p ${SSH_PORT} ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
    # 设置网站目录权限
    chmod -R 755 /var/www/hexo
    # 设置 index.html 为可读
    find /var/www/hexo -type f -exec chmod 644 {} \;
    echo "权限设置完成"
ENDSSH

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：权限设置失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 权限设置成功${NC}"

# 4. 重启 Nginx
echo -e "\n${YELLOW}[4/4] 重启 Nginx 服务...${NC}"

ssh -p ${SSH_PORT} ${SERVER_USER}@${SERVER_IP} "systemctl restart nginx"

if [ $? -ne 0 ]; then
    echo -e "${RED}错误：Nginx 重启失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Nginx 重启成功${NC}"

# 完成
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   部署完成！🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n访问你的网站：https://liguangjing.top"
echo -e "查看部署日志：ssh ${SERVER_USER}@${SERVER_IP} 'tail -f /var/log/nginx/error.log'"
echo ""

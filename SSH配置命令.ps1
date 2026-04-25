# SSH 免密登录配置命令
# 在管理员 PowerShell 中执行这些命令

# 1. 检查 OpenSSH 状态
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# 2. 配置并启动 SSH Agent（使用正确的方法）
# 方法 A：使用 sc.exe 而不是 sc
sc.exe config ssh-agent start= auto
sc.exe start ssh-agent

# 3. 验证服务状态
Get-Service ssh-agent

# 4. 查看密钥文件
Get-ChildItem $env:USERPROFILE\.ssh\

# 5. 添加密钥（如果找到密钥文件）
ssh-add $env:USERPROFILE\.ssh\id_ed25519

# 6. 测试连接
ssh root@175.178.189.55 "echo 'SSH 免密登录成功！'"

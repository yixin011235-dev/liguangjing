# SSH 免密登录配置指南

> 如果你之前配置过 SSH 密钥但仍然需要密码，运行这个脚本即可修复

---

## 🚀 快速修复

**双击运行：** `SSH密钥配置.bat`

它会自动：
1. ✅ 启动 SSH Agent 服务
2. ✅ 检查密钥文件
3. ✅ 添加密钥到 SSH Agent
4. ✅ 测试连接

---

## 📋 手动配置步骤

如果自动脚本不起作用，按以下步骤操作：

### 步骤 1：启动 SSH Agent

**在 PowerShell 中执行：**
```powershell
# 启动服务
net start ssh-agent

# 或设置自动启动（推荐）
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
```

### 步骤 2：检查密钥文件

检查是否存在密钥文件：
```powershell
# 查看已有密钥
Get-ChildItem $env:USERPROFILE\.ssh\

# 常见的密钥文件名：
# - id_ed25519（ed25519 密钥）
# - id_rsa（RSA 密钥）
# - id_ecdsa（ECDSA 密钥）
```

### 步骤 3：添加密钥到 SSH Agent

```powershell
# 添加 ed25519 密钥
ssh-add $env:USERPROFILE\.ssh\id_ed25519

# 或添加其他密钥
ssh-add $env:USERPROFILE\.ssh\id_rsa
```

### 步骤 4：测试连接

```powershell
ssh -o StrictHostKeyChecking=no root@175.178.189.55
```

如果不需要输入密码，说明配置成功 ✅

---

## 🔧 完整配置流程（如果还没有密钥）

### 1. 生成 SSH 密钥

```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

按 Enter 接受默认位置，设置密码（可选）。

### 2. 查看公钥

```powershell
cat $env:USERPROFILE\.ssh\id_ed25519.pub
```

复制输出的内容。

### 3. 上传公钥到服务器

**方法 A：使用 ssh-copy-id**
```powershell
ssh-copy-id root@175.178.189.55
```

**方法 B：手动上传**
```powershell
# 复制公钥到服务器
scp $env:USERPROFILE\.ssh\id_ed25519.pub root@175.178.189.55:~/

# SSH 到服务器
ssh root@175.178.189.55

# 在服务器上执行
mkdir -p ~/.ssh
cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
rm ~/id_ed25519.pub
exit
```

### 4. 测试免密登录

```powershell
ssh root@175.178.189.55
```

应该不需要密码即可登录！

---

## 🆘 常见问题

### Q: ssh-add 命令报错 "Could not open a connection to your authentication agent"

**原因：** SSH Agent 未运行

**解决：**
```powershell
# 启动 SSH Agent
net start ssh-agent

# 或
eval $(ssh-agent -s)
```

### Q: 仍然需要输入密码

**检查项：**
1. ✅ 服务器上是否有你的公钥？
   ```powershell
   ssh root@175.178.189.55 "cat ~/.ssh/authorized_keys"
   ```

2. ✅ 公钥格式是否正确？（应该在同一行，没有换行）

3. ✅ 服务器文件权限是否正确？
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

### Q: 如何删除已添加的密钥？

```powershell
ssh-add -d $env:USERPROFILE\.ssh\id_ed25519
```

### Q: 如何查看已添加的密钥？

```powershell
ssh-add -l
```

---

## 📂 相关文件位置

**本地：**
- SSH 密钥目录：`C:\Users\你的用户名\.ssh\`
- 私钥：`id_ed25519`（或 `id_rsa`）
- 公钥：`id_ed25519.pub`（或 `id_rsa.pub`）
- SSH 配置：`config`（可选）

**服务器：**
- SSH 配置目录：`~/.ssh/`
- 授权密钥：`~/.ssh/authorized_keys`

---

## ✅ 验证配置成功

执行以下命令，应该**不需要密码**即可连接：

```powershell
ssh root@175.178.189.55 "echo '免密登录成功！'"
```

如果看到"免密登录成功！"，说明配置成功 ✅

---

## 🎯 下一步

配置成功后，运行：

```powershell
.\deploy.ps1
```

即可自动部署博客！

---

## 💡 提示

- **首次配置**：只需要执行一次完整流程
- **之后使用**：只需启动 SSH Agent 即可
- **开机自启**：建议将 SSH Agent 设置为自动启动

---

遇到问题随时问我！ 😊

# SSH 公钥添加步骤（只需一次）

---

## 🎯 快速完成

### 第一步：复制这整段命令

```powershell
ssh root@175.178.189.55 "mkdir -p ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiGxl05gas1WsyFQFp3XAXz1OVjU3SlxC6CFL2EcU8Y my-laptop' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && echo '公钥添加成功！'"
```

### 第二步：粘贴到 PowerShell

在 PowerShell 窗口中**右键点击**粘贴，或者按 **Ctrl+V**

### 第三步：按回车执行

会提示输入服务器密码（最后一次！）

```
root@175.178.sj55's password: **********
```

输入密码后，会显示 **"公钥添加成功！"**

---

## 测试免密登录

执行成功后，测试一下：

```powershell
ssh root@175.178.189.55 "echo 'SSH 免密登录成功！'"
```

**如果不需要密码，直接显示"SSH 免密登录成功！"，说明配置成功！**

---

## 如果测试成功，运行部署

```powershell
cd d:\my-blog
.\deploy.ps1
```

**完全自动化，无需密码！**

---

## 如果失败，查看原因

```powershell
# 查看服务器上的 authorized_keys 文件
ssh root@175.178.189.55 "cat ~/.ssh/authorized_keys"
```

看看是否包含你的公钥 `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...`

---

## 常见问题

### Q: 命令执行后显示 "公钥添加成功！" 但测试还需要密码

**检查：**
```powershell
# 查看服务器上是否有你的公钥
ssh root@175.178.189.55 "cat ~/.ssh/authorized_keys"
```

如果没有显示 `ssh-ed25519 AAAAC3Nza...`，说明添加失败了。

**重新执行：**
```powershell
# 先清空，再重新添加
ssh root@175.178.189.55 "mkdir -p ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiGxl05gas1WsyFQFp3XAXz1OVjU3SlxC6CFL2EcU8Y my-laptop' > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

### Q: "Permission denied (publickey)"

可能 SSH Agent 未启动，重新执行：
```powershell
net start ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
ssh root@175.178.189.55
```

---

## ✅ 成功后

**以后每次部署只需：**

1. 打开普通 PowerShell
2. 执行 `cd d:\my-blog; .\deploy.ps1`
3. 等待 1-2 分钟
4. 访问 https://liguangjing.top

**完全自动化！无需任何密码！** 🎉

---

## 📁 已为你准备的文件

```
d:\my-blog\
├── 执行公钥上传.bat          ← 双击执行这个
├── deploy.ps1               ← 部署脚本
└── ...
```

---

现在去执行那个命令吧！把结果发给我！ 💪

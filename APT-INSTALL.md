# 在裸 Termux 中用 APT 安装 GodotJS

这是独立的第三方测试软件源，不是 Termux 官方源。仅支持标准路径的裸 Termux `aarch64`，不适用于 proot Ubuntu。X11、Zink/Turnip 及 GodotJS 脚本仍需手机实机验证；驱动不包含在包中。

## 首次添加软件源

在手机 Termux 执行（无需 root / sudo）：

```bash
pkg install x11-repo curl gnupg
curl -fL --retry 3 \
  https://raw.githubusercontent.com/NoviaDroid/godotjs-termux-x11/main/scripts/setup-apt-termux.sh \
  -o setup-godotjs-apt.sh
# 可先查看脚本：less setup-godotjs-apt.sh
bash setup-godotjs-apt.sh
apt install godotjs
```

脚本校验下载公钥的 SHA-256，再使用仅限本源的 `signed-by` 配置。APT 依次校验签名、软件包索引和 `.deb` 的哈希；不使用 `trusted=yes` 或 `--allow-unauthenticated`。脚本还添加优先级规则，只允许此源提供 `godotjs`，不接管其他系统包。

软件源地址：`https://noviadroid.github.io/godotjs-termux-x11`，发行目录 `stable`、组件 `main`。`stable` 只是目录名，不代表这个尚未手机实测的构建已达到稳定发布质量。

公钥指纹：

```text
48E7 ED57 572A 8C4C C514 B551 3831 C8F7 BE1B 2071
```

公钥文件 SHA-256：`4aec9cf09aa248c70d0e12effedb5eba905736d8905c1c2421af3b2b27b5d6b8`。

首次信任仍依赖本 GitHub 仓库和 HTTPS；签名不是对程序安全性或 GPU 兼容性的保证。不要从不明来源替换公钥。如果出现过期或签名错误，报告问题，不要关闭校验。

## 更新

```bash
apt update
apt install --only-upgrade godotjs
```

只有维护者发布新版本并更新签名索引后才会有更新。目前版本为 `4.6.1-1`。`apt policy godotjs` 可查看候选版本及软件源。

## 启动

先启动已配置好的 Termux:X11/XFCE，沿用有效的 Mesa/Turnip 驱动和 ICD 环境设置：

```bash
export DISPLAY=:0
# OpenGL Compatibility -> Zink -> Turnip
MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink \
  godotjs --display-driver x11 --rendering-driver opengl3 --rendering-method gl_compatibility
# 或另一次运行时使用 Vulkan Mobile -> Turnip
godotjs --display-driver x11 --rendering-driver vulkan --rendering-method mobile
```

若依赖解析提示需要移除现有驱动，先取消安装并提供完整错误，不要强制覆盖。按 [手机验收清单](PHONE-HANDOFF.md) 分别检查窗口、两种渲染路径和脚本执行。

## 撤销本软件源

在 `$PREFIX/etc/apt/sources.list.d/godotjs.list` 中注释该源，然后运行 `apt update`。这不会卸载已安装的程序；卸载程序使用 `apt remove godotjs`。

## 维护者说明

私钥不在 GitHub 或 Actions secrets 中。由维护者在受控的本地 GnuPG 目录中运行 `scripts/sign-apt-repo.sh`，提交公钥和已签名的元数据。Actions 只下载已发布 `.deb`、验证哈希与签名，再部署 Pages，不持有签名私钥。

更新包时同时更新 `.github/workflows/apt-pages.yml` 中的 Release URL、文件名和 SHA-256，再重新生成签名索引。索引有效期为 180 天；即使没有新版本，也必须在到期前重新签名。签名密钥有效期为两年；备份私钥与撤销证书，不要将它们放进仓库。不要自动关闭过期检查。

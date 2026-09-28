# GodotJS QuickJS-NG — bare Termux ARM64 / X11

为裸 Termux（Android Bionic / aarch64）构建 Godot 4.6.1 编辑器，集成 GodotJS 的 QuickJS-NG 后端。不是 APK，不需要 proot Ubuntu。

编译启用 X11、OpenGL 3 和 Vulkan。面向 Snapdragon 8 Gen 2 / Adreno 740，手机可选择 OpenGL → Zink → Turnip，或 Vulkan → Turnip。驱动不打包，实际 GPU 兼容性仍须在手机验证。

## Windows / WSL2 构建

在 WSL2 Ubuntu 安装 Docker Engine、Git 和 Python 3，并启动 Docker。将本仓库放在 WSL 可访问的位置，执行：

```bash
sudo bash scripts/build-wsl.sh /opt/godotjs-rebuild
```

工作目录必须尚不存在，推荐使用 WSL 的 Linux 文件系统，不要放在 `/mnt/c`。脚本下载固定版本的 Termux 构建框架、GodotJS 和官方构建镜像，并交叉编译 ARM64 `.deb`。首次构建需要较多磁盘空间和下载量。当前配置使用 8 个编译任务；保持 WSL 和电脑运行。

如果中途失败，不要删掉缓存重来。修复后在同一容器继续：

```bash
docker start godotjs-rebuild
docker exec godotjs-rebuild bash -lc \
  'cd /home/builder/termux-packages && ./build-package.sh -a aarch64 -I -c godotjs'
```

包输出位于工作目录的 `termux-packages/output/`。容器默认保留用于增量重编译，脚本不会删除它。

## 手机安装及启动

先准备正在运行的 Termux:X11 / XFCE，以及适用于裸 Termux 的 Mesa Zink / Turnip。不要安装 Ubuntu 的 glibc 驱动包。

```bash
pkg install x11-repo
apt update
apt install ./godotjs_实际版本_aarch64.deb
export DISPLAY=:0
bash scripts/launch-phone.sh zink
# 或直接 Vulkan（Mobile 渲染器）
bash scripts/launch-phone.sh vulkan
```

文件名以实际生成的包为准。启动器不会覆盖 Vulkan ICD 路径；沿用手机已验证的驱动配置。

首次测试时检查 `vulkaninfo --summary` 和 `glxinfo -B`，应分别看到 Turnip/Adreno 和 Zink，而非软件渲染。再分别启动两种渲染模式、建立最小 GodotJS 项目验证脚本。构建成功不等于已通过手机实机测试。

固定版本、补丁来源及架构说明见 [BARE-TERMUX.md](BARE-TERMUX.md)。旧的 proot 构建脚本已停用。

# 手机端验收 / 给 Termux 助手的任务

目标是裸 Termux aarch64 + 已有 Termux:X11/XFCE，设备为 Snapdragon 8 Gen 2 / Adreno 740。不要使用 proot，不要安装 Ubuntu glibc 包。此构建是 Godot 4.6.1 + GodotJS QuickJS-NG 的独立 `godotjs` 命令。

1. 确认 `uname -m` 为 `aarch64`、`PREFIX` 为 `/data/data/com.termux/files/usr`，记录 Android/Termux 版本。若不符，停止安装并报告。
2. 核对下载文件的 SHA-256。启用 Termux X11 仓库后，用 `apt install ./实际文件名.deb` 安装；若出现依赖冲突，报告冲突，不要强制安装或卸载现有 Mesa/驱动。
3. 确认 Termux:X11 与 XFCE 正常运行，使用它实际的 `DISPLAY`。运行 `bash scripts/check-phone.sh` 保存输出。缺少检查工具时先说明，不要据此断言驱动不可用。
4. `godotjs --headless --version` 应能启动。运行 `bash scripts/launch-phone.sh zink --verbose`，确认 OpenGL Compatibility 渲染器、Zink 和 Adreno GPU，排除 llvmpipe/lavapipe。
5. 另开一次 `bash scripts/launch-phone.sh vulkan --verbose`，检查 Vulkan Mobile 渲染器和 Turnip。不要同时启动多个测试实例。
6. 在单独的临时项目内，通过 GodotJS 提供的项目初始化功能配置 TypeScript，建立最小脚本并打印一条消息，验证 QuickJS-NG 执行路径。不要修改已有项目来做实验。
7. 分别报告：二进制启动、X11 窗口、Zink 渲染、直接 Vulkan 渲染、GodotJS 脚本执行。任何失败请保留完整错误及相关驱动版本；不要把“窗口能打开”当成所有测试通过。

驱动不包含在安装包中。保留现有 `VK_DRIVER_FILES` / `VK_ICD_FILENAMES` 配置；不要猜测 ICD JSON 路径，不要未经确认替换工作中的 Turnip/Mesa。PC 端交叉编译无法代替这些手机实机测试。

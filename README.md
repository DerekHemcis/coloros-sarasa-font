# ColorOS 全局系统字体替换模块（Sarasa Mono SC）

把 ColorOS（OPPO / OnePlus / realme）的系统字体**全局**替换为 **Sarasa Mono SC SemiBold（等距更纱黑体）**，基于 KernelSU / Magisk 模块，**systemless、可随时回滚**。

> 适用于 ColorOS 16（Android 16）。其它 ColorOS 版本字体文件结构可能不同，需自行调整。

---

## ✨ 特性

- **全局生效**：设置、桌面、微信、系统 UI……所有界面统一换成新字体
- **中文也替换**：不仅是拉丁字母，简体 / 繁体中文一并替换
- **systemless**：不改动 `/system` 分区，通过 `mount --bind` 运行时挂载
- **可回滚**：删除模块 + 重启即可完全恢复原厂字体
- **开机自动**：`post-fs-data.sh` 在每次开机时自动挂载

---

## 🔍 原理

ColorOS 16 的字体体系有几个关键点：

```
/system/fonts/
├── SysFont-Regular.ttf        → 符号链接 → /data/format_unclear/font/OplusOSUI-Regular.ttf → /system/fonts/Roboto-Regular.ttf
├── Roboto-Regular.ttf         实体文件（默认回退字体族）
├── SysSans-En-Regular.ttf     实体文件（英文，要求 PostScript 名 OPlusSansEn）
├── SysSans-Hans-Regular.ttf   实体文件（简体中文，要求 PostScript 名 OPPO_Sans_4.0_SC）
└── SysSans-Hant-Regular.ttf   实体文件（繁体中文，要求 PostScript 名 OPPO_Sans_4.0_TC）
```

`/system/etc/fonts.xml` 里这些字体族带有 `postScriptName="..."` 属性，
**如果字体文件内部的 PostScript 名不匹配，字体族会加载失败，中文会回落到 `NotoSansCJK`。**

因此本模块提供了 **4 个已打好补丁** 的字体文件：
在原字体（PostScript 名 `Sarasa-Mono-SC-SemiBold`）的 `name` 表中，
把 **PostScript 名（nameID=6）** 就地改写为 ColorOS 期望的值，其余数据完全不动。

改动位置（针对本字体文件）：

| 项目 | 值 |
|---|---|
| PostScript 名字符串偏移 | `25434686` |
| PostScript 名长度字段偏移 | `25433942` |

---

## 📦 安装

### 方式一：手动复制（推荐）

```bash
# root 环境下执行
cp -r sarasa_system_font /data/adb/modules/
chmod -R 755 /data/adb/modules/sarasa_system_font
# 重启
```

### 方式二：打包成 zip 后刷入

```bash
cd sarasa_system_font && zip -r ../sarasa_system_font.zip . -x '.*'
# 然后在 KernelSU / Magisk Manager 里刷入 zip
```

重启后生效。

---

## 🗂 目录结构

```
sarasa_system_font/
├── module.prop           模块信息
├── post-fs-data.sh       开机自动挂载脚本
└── fonts/
    ├── Roboto-Regular.ttf          (原版，无 postScriptName 要求)
    ├── SysSans-En-Regular.ttf      (补丁: OPlusSansEn)
    ├── SysSans-Hans-Regular.ttf    (补丁: OPPO_Sans_4.0_SC)
    └── SysSans-Hant-Regular.ttf    (补丁: OPPO_Sans_4.0_TC)
```

---

## 🔄 回滚

任选其一：

1. **KernelSU / Magisk Manager** → 模块 → 禁用 / 卸载 `Sarasa Mono SC 系统字体` → 重启
2. **命令行**：
   ```bash
   touch /data/adb/modules/sarasa_system_font/disable   # 禁用
   # 或者
   rm -rf /data/adb/modules/sarasa_system_font          # 完全删除
   # 然后重启
   ```
3. **开机安全模式**：开机时按住「音量下」→ KernelSU 会临时禁用所有模块

重启后即恢复原厂字体（`/system` 从未被修改）。

---

## ⚠️ 已知问题

### 1. 与 mountify 元模块冲突

如果你的设备安装了 **mountify** 作为元模块（metamodule），要注意：

- 它可能会因 **anti-bootloop** 机制自我禁用（`module.prop` 里会显示 `anti-bootloop triggered`）
- 一旦 mountify 被禁用，**所有模块的 `system/` 目录都不会被挂载**

本模块**不依赖挂载机制**——它用 `post-fs-data.sh` 自己执行 `mount --bind`，
所以即使 mountify 处于禁用状态也能正常工作。

### 2. 字体只有单一字重

Sarasa Mono SC SemiBold 只有一个字重，**加粗文字由系统合成**（笔画会更粗一点）。
如果想要完整的 Regular / Bold / Italic 多字重，可以换用 Sarasa Gothic 的其它字形，
并相应调整 `fonts/` 下的文件。

### 3. 等宽特性

这是 **Mono（等宽）** 字体，英文和数字会等宽显示（打字机风格）。
如果只想要等宽中文、比例英文，可以换用 **Sarasa Gothic SC**（非 Mono 版）。

---

## 📄 许可

- 模块脚本：MIT
- 字体：**Sarasa Gothic / 更纱黑体**，作者 [be5invis](https://github.com/be5invis/Sarasa-Gothic)，
  以 **SIL Open Font License 1.1** 发布，允许自由分发与修改。

---

## 🙏 致谢

- [Sarasa Gothic / 更纱黑体](https://github.com/be5invis/Sarasa-Gothic) — 字体
- [KernelSU](https://kernelsu.org/) — root 方案

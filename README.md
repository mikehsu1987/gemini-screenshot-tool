# Gemini Tool

一个 macOS 小工具集，包含两个独立的小工具。

---

## 1. Gemini Tool.app

用 **Google Chrome app 模式**打开或聚焦 Gemini。

双击：

```text
Gemini Tool.app
```

它会：

1. 如果 Gemini 独立窗口不存在，打开一个 Chrome app 模式窗口
2. 第一次默认放在屏幕右侧，尺寸约 `460 × 760`
3. 如果 Gemini 独立窗口已存在，直接聚焦它
4. 窗口可以手动拖动、缩放、最小化、关闭
5. 后续再次打开时，不会强制覆盖你手动调整过的窗口大小

也可以在命令行调用：

```text
open-gemini.command
```

## 2. 截图面板.app

一个独立浮动的「截图询问」按钮面板，不绑定任何 App。

双击：

```text
Gemini Panel.app   （系统显示为"截图面板"）
```

点击「截图询问」：

1. 面板自动隐藏
2. 进入框选截图模式
3. 截图复制到系统剪贴板
4. 面板恢复显示
5. 你在输入框里按 `⌘V` 粘贴即可

截完图想粘到 Gemini、Claude、备忘录、任何地方都行。

注意：截图会留在系统剪贴板里。如果截图包含隐私内容，用完后可以复制一段普通文字覆盖它。

也可以在命令行调用：

```text
gemini-panel.command
```

## 这两个工具的关系

- **互相独立**，不依赖彼此
- 可以同时开，也可以只开一个
- 想关哪个关哪个，不影响另一个

## 鉴权

这个工具不做任何 Google 鉴权，也不保存账号密码。

它只是用 Chrome 打开：

```text
https://gemini.google.com/app
```

所以会使用 Chrome 自己的 Google 登录状态。

## 是否影响 Chrome 本身？

正常不会。

这个工具不会修改：

- Chrome 默认配置
- 默认浏览器
- Chrome profile
- 插件
- 全局缩放
- Cookies

它会记录自己创建的 Gemini 窗口 ID，之后只聚焦这个窗口，避免误操作普通 Chrome 标签页。

## 字体大小

如果想放大字体，可以在 Gemini 窗口里按：

```text
⌘ + 加号
```

缩小：

```text
⌘ + 减号
```

Chrome 通常会按站点记住缩放，不会改全局系统字体。

## 如果 macOS 阻止打开

第一次双击 `.app` 或 `.command` 文件时，macOS 可能提示安全限制。

可以右键 → 打开。

## 文件说明

- `Gemini Tool.app`：打开或聚焦 Gemini 的小工具
- `Gemini Panel.app`：浮动截图按钮面板（系统显示为"截图面板"）
- `GeminiPanel.swift`：面板源码
- `gemini-toggle.applescript`：打开/聚焦 Gemini 的核心 AppleScript
- `open-gemini.command`：打开/聚焦 Gemini 的命令行包装脚本
- `gemini-panel.command`：截图面板的命令行包装脚本
- `README.md`：说明文档

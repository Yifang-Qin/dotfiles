local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ============================================================
-- 配色 / 字体
-- ============================================================
config.color_scheme = 'Gruvbox Dark (Gogh)'
-- 用 Mono 变体：nerd 图标压成单宽（非 Mono 变体图标是 1.5 宽，会撑乱对齐）
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font Mono',
  'PingFang SC',
}
config.font_size = 18.0

-- wezterm 默认会把 bold + ANSI 0-7 的文本自动提亮一档（红→亮红、黑→灰），
-- 关掉它，让 git/ls/npm 等命令输出严格按 Gruvbox 的 16 色调色板显示
config.bold_brightens_ansi_colors = 'No'

-- 不闪烁的块状光标
config.default_cursor_style = 'SteadyBlock'

-- ============================================================
-- 窗口
-- ============================================================
config.initial_cols = 90
config.initial_rows = 20

-- 去掉窗口内边距（wezterm 默认 left/right = '1cell'、top/bottom = '0.5cell'，
-- 18pt 字号下相当宽）
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- 去掉原生标题栏，红绿灯按钮（macOS 原生样式）集成进 tab bar
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.integrated_title_button_style = 'MacOsNative'

-- 回滚缓冲 10 万行（wezterm 默认 3500 行偏小）
config.scrollback_lines = 100000

-- 固定初始窗口位置 (220, 140)。
-- wezterm 没有静态窗口位置选项，只能在 GUI 启动时通过 mux 设置。
-- 注意：仅对 `wezterm start` 拉起的首个窗口生效（cmd+N 新窗口不受控），
-- 且 macOS 上窗口会先出现在默认位置再瞬移（上游 issue #2976）。
wezterm.on('gui-startup', function(cmd)
  local args = cmd or {}
  args.position = { x = 220, y = 140 }
  wezterm.mux.spawn_window(args)
end)

-- ============================================================
-- Tab bar（retro 风格 + gruvbox 配色）
-- ============================================================
-- 试过 fancy（圆角卡片式 tab + 独立 UI 字体）：红绿灯与首 tab 的间距
-- 撞上游 bug 无干净解法（见下方 ⚠️），整体观感不佳，切回 retro。
config.use_fancy_tab_bar = false
-- 红绿灯画在 tab bar 里，隐藏 tab bar 会一起丢掉按钮，所以让它常驻
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- ⚠️ fancy + INTEGRATED_BUTTONS 下别用 set_left_status 给「红绿灯 ↔ 首 tab」垫间距：
-- left status 会被直接画进 macOS 红绿灯底下，露出一块色斑（上游 bug，至今 open：
-- wezterm/wezterm#7551、#7197）。retro 模式不受此 bug 影响，需要垫间距时
-- left status 塞空格的做法可以用。

-- retro + MacOsNative 下，红绿灯的预留空位是源码硬编码的 10 个 cell
-- （tabbar.rs：`for _ in 0..10 { line.insert_cell(0, …) }`），无配置项可调；
-- 18pt 字体下 ≈108px，比按钮实际所需（~65px）宽出一截，属已知观感损耗；
-- 想完全控制间距只能换 integrated_title_button_style = 'Windows'/'Gnome'
-- 字符按钮（不走这段预留逻辑，但失去原生红绿灯外观）。
-- 下面的空 left status 仅用于清掉历史 set_left_status 的运行时残留
-- （热重载不清 window 状态，残留会再垫宽 2 cell）；留着无害。
wezterm.on('update-status', function(window, _)
  window:set_left_status('')
end)

config.colors = {
  tab_bar = {
    background = '#1d2021', -- gruvbox bg0_hard，比终端背景略暗
    active_tab = {
      bg_color = '#282828', -- 与终端背景同色，视觉上与内容连成一片
      fg_color = '#fabd2f', -- bright yellow
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#1d2021',
      fg_color = '#928374', -- gray
    },
    inactive_tab_hover = {
      bg_color = '#3c3836', -- bg1
      fg_color = '#ebdbb2', -- fg
      italic = false,
    },
    new_tab = {
      bg_color = '#1d2021',
      fg_color = '#928374',
    },
    new_tab_hover = {
      bg_color = '#3c3836',
      fg_color = '#ebdbb2',
    },
  },
}

-- ============================================================
-- 鼠标：选中即复制、cmd+点击开链接
-- wezterm 默认选择只写 PrimarySelection（macOS 上等于没进系统剪贴板），
-- 且默认单击就直接打开链接 —— 这两点都改掉
-- ============================================================
config.mouse_bindings = {
  -- 单击 / 双击选词 / 三击选行，松开即复制到系统剪贴板
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'Clipboard',
  },
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'Clipboard',
  },
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'Clipboard',
  },
  -- 拖拽选择松开后同样复制
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.ExtendSelectionToMouseCursor 'Cell',
  },
  -- cmd + 点击打开链接
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
  -- 抑制 cmd+点击的 down 事件传给终端程序
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.Nop,
  },
}

return config

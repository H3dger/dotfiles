-- 加载 wezterm API 和获取 config 对象
local wezterm = require 'wezterm'
local config = wezterm.config_builder()


config.launch_menu = {
  {
    label = 'PoserShell',
    args = { 'powershell.exe', '-NoLogo' },
  },
  {
    label = "Cmd",
    args = { 'cmd.exe'}
  }
}

-------------------- 颜色配置 --------------------
config.color_scheme = 'Catppuccin Mocha'
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8,
}

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)



-- 设置字体和窗口大小
config.font = wezterm.font("Maple Mono NF CN")
config.font_size = 16
config.initial_cols = 140
config.initial_rows = 30
-- 设置默认的启动shell

-- COMSPEC 是 Windows 系统的一个重要环境变量，通常默认指向 cmd.exe。覆盖它可能导致其他应用程序启动时依赖 COMSPEC 的功能出现异常。
-- config.set_environment_variables = {
--   COMSPEC = 'C:\\Users\\97766\\AppData\\Local\\Programs\\nu\\bin\\nu.exe',
-- }

-- config.default_prog = { 'C:\\Users\\97766\\AppData\\Local\\Programs\\nu\\bin\\nu.exe' }


-------------------- 键盘绑定 --------------------
local act = wezterm.action

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'q',          mods = 'LEADER',         action = act.QuitApplication },

  { key = 'h',          mods = 'LEADER',         action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'v',          mods = 'LEADER',         action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'q',          mods = 'CTRL',           action = act.CloseCurrentPane { confirm = false } },

  { key = 'LeftArrow',  mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Down' },

  -- CTRL + T 创建默认的Tab
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'DefaultDomain' },
  -- CTRL + W 关闭当前Tab
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab { confirm = false } },

  -- CTRL + SHIFT + 1 创建新Tab - WSL
  {
    key = '!',
    mods = 'CTRL|SHIFT',
    action = act.SpawnCommandInNewTab {
      domain = 'DefaultDomain',
      args = {'wsl', '-d', 'Ubuntu-20.04'},
    }
  },
  {
    key = '@',
    mods = 'CTRL|SHIFT',
    action = act.SpawnCommandInNewTab {
      args = {'cmd'},
    }
  },
  {
    key = '#',
    mods = 'CTRL|SHIFT',
    action = act.SpawnCommandInNewTab {
      domain = 'DefaultDomain',
      args = {'pwsh'},
    }
  }
}

for i = 1, 8 do
  -- CTRL + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL',
    action = act.ActivateTab(i - 1),
  })
end

-------------------- 鼠标绑定 --------------------
config.mouse_bindings = {
  -- copy the selection
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },

  -- Open HyperLink
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-------------------- 窗口居中 --------------------
wezterm.on("gui-startup", function(cmd)
        local screen = wezterm.gui.screens().active
        local width, height = screen.width * 0.5, screen.height * 0.5
        local tab, pane, window = wezterm.mux.spawn_window(cmd or {
                position = {
            x = (screen.width - width) / 2,
            y = (screen.height - height) / 2,
            origin = {Named=screen.name}
        }
        })
        window:gui_window():set_inner_size(width, height)
end)

-- 设置窗口透明度
config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 10




return config

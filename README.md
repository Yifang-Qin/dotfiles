# Personal development environment

使用 Git 保存配置，用 [Dotbot](https://github.com/anishathalye/dotbot) 将配置软链接到应用读取的位置。
当前管理 WezTerm、Ghostty、Zed（设置和主题）以及 MiniMax Code 的自定义主题，配置从本机导入。
Zed 的模型 provider、默认模型和 SSH 连接只保存在本机，不进仓库，见 [Zed](#zed)。

## 目录与映射

| 仓库文件 | 安装位置 |
| --- | --- |
| `wezterm/wezterm.lua` | `~/.wezterm.lua` |
| `ghostty/config.ghostty` | `${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `zed/themes/` | `~/.config/zed/themes`（整个目录） |
| `mcode/themes/` | `~/.minimax/tui/themes`（整个目录） |
| `install.conf.yaml` | Dotbot 链接清单 |
| `dotbot/` | Git 子模块，固定在仓库记录的提交 |

主题目录整体链接，新增主题直接放进对应目录即可，无需重新运行 `./install`。
Zed 在 macOS 上固定读取 `~/.config/zed`，不受 `XDG_CONFIG_HOME` 影响。

## 新机器安装

需要 Git、Python 3，以及已安装的 WezTerm、Ghostty、Zed 和 MiniMax Code。
当前配置使用 JetBrainsMono Nerd Font Mono；WezTerm 另有 macOS 的 PingFang SC 回退字体。
macOS 可按需用 Homebrew 安装应用和字体（MiniMax Code 按其官方方式安装）：

```sh
brew install --cask wezterm ghostty zed font-jetbrains-mono-nerd-font
git clone --recurse-submodules https://github.com/Yifang-Qin/dotfiles.git ~/dotfiles
cd ~/dotfiles
git config user.name FangFang
git config user.email 91451403+Yifang-Qin@users.noreply.github.com
./install --dry-run
./install
```

仓库是公开的。克隆后先按上面设置本仓库的提交身份，用 GitHub 的 noreply 邮箱，避免全局邮箱进入公开历史。

`./install` 可重复运行，支持从任意工作目录调用；首次运行会初始化缺失的 Dotbot 子模块。
预览不会修改配置链接，但仍可能下载/初始化子模块。
安装器会拒绝覆盖已有的普通文件或目录，请先比较并将旧配置移到仓库外的备份目录，再安装。
已有软链接可重新指向本仓库。移动仓库后需要再次运行 `./install`。

Ghostty 使用 `config.ghostty` 文件名，需要支持该文件名的版本（1.2.3+）。
迁移时还要检查 Ghostty 旧的 `config` 文件和 macOS 的
`~/Library/Application Support/com.mitchellh.ghostty/`，避免其他配置覆盖仓库设置。
详见 [Ghostty 配置位置](https://ghostty.org/docs/config)。

Zed 还需要手动创建本机的 `global_settings.json`，MiniMax Code 需要选择一次主题，见下方对应小节。

当前配置保留 macOS 的标题栏、CMD 鼠标绑定、字体和窗口位置偏好。
跨 macOS 机器可直接复用；迁移 Linux 时应按需要调整这些设置，并安装对应字体。
安装器负责链接配置，不会安装应用或字体。

## Zed

仓库管理 `settings.json` 和 `themes/`，扩展通过 `settings.json` 的 `auto_install_extensions` 声明。
`themes/gruvbox-deep-dark.json` 基于 Zed 自带的 Gruvbox 主题修改，许可证见 `zed/LICENSE-gruvbox`。
`zed/themes/` 里只放主题文件：Zed 会尝试把其中每个文件都当主题加载。
以下本机配置放在 `~/.config/zed/global_settings.json`，不进仓库：

- `language_models`：模型 provider；
- `agent.default_model`：默认模型（`agent.favorite_models` 等其他模型选择同理）；
- `ssh_connections`：SSH 服务器和远程项目。

Zed 先读 `global_settings.json`，再用 `settings.json` 覆盖：对象逐字段合并，数组整体覆盖。
Zed 不会修改 `global_settings.json`，界面上的改动都写入 `settings.json`，也就是仓库文件：

- 在 Agent 面板切换或收藏模型，会写入 `agent.default_model` 或 `agent.favorite_models`，
  提交前用 `git diff` 检查并移回 `global_settings.json`；
- 界面新增的 SSH 服务器会写入 `settings.json`，并整体遮盖 `global_settings.json` 里的列表，需要合并回去；
- `global_settings.json` 里的服务器，在界面上改昵称、删除或记录新打开的目录都不会生效，需直接编辑该文件。

新机器上需手动创建 `global_settings.json`；API Key 不在配置文件里，需在 Zed 中重新填写。
`prompts/`（数据库）和 `~/Library/Application Support/Zed/`（扩展、缓存等运行数据）不纳入管理。
以后新增 `keymap.json`、`tasks.json`、`snippets/` 等配置时，放进 `zed/` 并在 `install.conf.yaml` 添加映射。

## MiniMax Code

`mcode/themes/` 链接到 mcode 默认数据目录下的 `~/.minimax/tui/themes`
（设置了 `MINIMAX_DATA_DIR` 时需相应修改映射）。mcode 启动时加载其中的主题，文件变化时自动重载。
当前选用的主题记录在 `~/.minimax/tui/tui-settings.json`；mcode 会整体替换该文件，不适合软链接，
新机器上用 `/theme` 选择一次 Gruvbox MCode Dark。

## 日常修改和同步

直接编辑仓库里的配置文件，应用会通过软链接读取相同内容。
WezTerm 通常自动重载配置；Ghostty 在 macOS 上按 `Cmd+Shift+,` 重载，部分设置需新建窗口；
Zed 会自动重载设置和主题，MiniMax Code 会自动重载主题。

```sh
git diff
git add wezterm ghostty zed mcode
TZ=UTC git commit -m "Update configuration"
git push
```

提交时加 `TZ=UTC`，让公开历史里的时间戳不带本地时区。

另一台机器更新：

```sh
git pull --ff-only
./install
```

当前没有配置自动同步任务。

## 备份与恢复

本机首次接管前的原始配置保存在 `~/.local/state/dotfiles-backups/` 下带时间戳的目录。
恢复时先用 `ls -l` 确认目标是本仓库创建的软链接，删除对应链接，再将备份复制回原位置。
不要直接覆盖软链接写入备份，否则会改到仓库源文件。
Zed 的 `global_settings.json` 只在本机，重装或迁移前请自行备份。

## 扩展其他工具

每个工具建立独立目录，将配置加入 Git，再在 `install.conf.yaml` 添加映射。
密钥、令牌和机器私有数据应保留在仓库外。

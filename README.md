# dotfiles

我的 macOS 终端和编辑器配置，用 [Dotbot](https://github.com/anishathalye/dotbot) 软链接到各应用的配置目录。

## 包含什么

| 仓库路径 | 链接到 |
| --- | --- |
| `wezterm/wezterm.lua` | `~/.wezterm.lua` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `zed/themes/` | `~/.config/zed/themes` |
| `mcode/themes/` | `~/.minimax/tui/themes` |
| `omp/themes/` | `~/.omp/agent/themes` |

链接清单在 `install.conf.yaml`，Dotbot 作为子模块放在 `dotbot/`。
主题目录整体链接，新主题放进去就能用。
Ghostty 的路径跟随 `XDG_CONFIG_HOME`，Zed 固定用 `~/.config/zed`。

## 安装

需要 Git、Python 3，以及 WezTerm、Ghostty、Zed、MiniMax Code、omp 和 JetBrainsMono Nerd Font。

```sh
brew install --cask wezterm ghostty zed font-jetbrains-mono-nerd-font
git clone --recurse-submodules https://github.com/Yifang-Qin/dotfiles.git ~/dotfiles
cd ~/dotfiles
git config user.name FangFang
git config user.email 91451403+Yifang-Qin@users.noreply.github.com
./install --dry-run
./install
```

- 两行 `git config` 让提交使用 GitHub 的 noreply 邮箱。
- `./install` 可以重复运行。它不会覆盖已有的普通文件，先把旧配置挪走再装；仓库换了位置要重新运行。
- Ghostty 需要 1.2.3+。旧的 `config` 文件和 `~/Library/Application Support/com.mitchellh.ghostty/` 里的配置要先移走。
- 配置按 macOS 写的，在 Linux 上要调整标题栏、鼠标绑定和字体。
- 装完还要为 Zed 创建 `global_settings.json`，并在 MiniMax Code 和 omp 里各选一次主题，见下文。

## Zed

仓库里放 `settings.json` 和主题，扩展用 `auto_install_extensions` 声明。
模型和 SSH 相关的本机配置写在 `~/.config/zed/global_settings.json`，不进仓库：

- `language_models`
- `agent.default_model`（以及 `agent.favorite_models`）
- `ssh_connections`

Zed 会合并这两个文件，同一字段以 `settings.json` 为准。

- 在界面里切换或收藏模型、新增 SSH 服务器，都会写进仓库里的 `settings.json`，新增的服务器还会盖掉本机列表。
  提交前看一眼 `git diff`，把这些内容挪回 `global_settings.json`。
- 本机列表里的 SSH 服务器在界面上改不了，直接编辑 `global_settings.json`。
- API Key 不在配置文件里，新机器上要在 Zed 里重新填。
- `zed/themes/` 里只放主题文件，Zed 会把其中每个文件都当主题加载。
  `gruvbox-deep-dark.json` 改自 Zed 自带的 Gruvbox，许可证见 `zed/LICENSE-gruvbox`。

## MiniMax Code

`mcode/themes/` 链接到 `~/.minimax/tui/themes`；设置了 `MINIMAX_DATA_DIR` 的话要改映射。
当前用哪个主题记在 `~/.minimax/tui/tui-settings.json`，这个文件不进仓库，新机器上用 `/theme` 选一次 Gruvbox MCode Dark。

## omp

`omp/themes/` 链接到 `~/.omp/agent/themes`，只管主题文件。
当前主题记在 `~/.omp/agent/config.yml` 的 `theme.dark` 里。这个文件还存着模型和角色等本机配置，不进仓库，新机器上在 omp 设置里选一次 `gruvbox-dark`。

## 日常使用

直接改仓库里的文件。WezTerm、Zed 和 MiniMax Code 会自动重载，Ghostty 按 `Cmd+Shift+,`。

```sh
git diff
git add wezterm ghostty zed mcode omp
TZ=UTC git commit -m "Update configuration"
git push
```

`TZ=UTC` 让提交时间不带本地时区。其他机器上同步：

```sh
git pull --ff-only
./install
```

## 备份与恢复

本机接管前的原配置备份在 `~/.local/state/dotfiles-backups/` 下的时间戳目录里。
恢复时先删掉对应的软链接，再把备份复制回去。不要直接往软链接里写，那会改到仓库文件。
`global_settings.json` 只在本机，记得自己备份。

## 添加新工具

给工具建一个目录放配置，再在 `install.conf.yaml` 加一行映射。密钥和本机私有数据不要放进仓库。

## 致谢

受 [magic3007/dotfiles](https://github.com/magic3007/dotfiles) 启发，同样用 Dotbot 管理。

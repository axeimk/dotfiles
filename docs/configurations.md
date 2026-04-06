# 設定ファイル詳細

## ~/.bashrc

Ubuntu デフォルトをベースにカスタマイズしたシェル設定。

- **ヒストリー**: 重複・スペース始まりを除外、ファイルに追記（上書きしない）、1000件保持
- **補完**: bash-completion を読み込み
- **エイリアス**:
  - `ls` / `ll` → `eza --icons`（モダンな ls 代替、アイコン付き）
  - `grep` / `fgrep` / `egrep` → カラー出力
- **開発ツールの初期化**:
  - [nvm](https://github.com/nvm-sh/nvm) — Node.js バージョン管理
  - [mise](https://mise.jdx.dev/) — ランタイムバージョン管理
  - [starship](https://starship.rs/) — プロンプト
- **PATH**: `~/.opencode/bin` を追加
- **Windows Terminal 連携**: `PROMPT_COMMAND` でカレントディレクトリを通知（タブ復元時にディレクトリも復元される）

## ~/.profile

ログインシェル起動時に読み込まれる設定。Ubuntu デフォルト。

- `.bashrc` の読み込み
- `~/bin`、`~/.local/bin` を PATH に追加

## ~/.gitconfig（テンプレート）

chezmoi テンプレートにより OS ごとに内容が分岐する。

**共通設定:**

| 設定 | 値 |
|------|-----|
| エディタ | VS Code (`code --wait`) |
| デフォルトブランチ | `main` |
| ユーザー名 | `axeimk` |
| Git LFS | 有効 |
| エイリアス | `st` → `status` |
| カラー出力 | `auto` |

**OS 別の分岐:**

| 設定 | Linux / WSL | Windows | Mac |
|------|------------|---------|-----|
| `excludesFile` | `~/.config/git/ignore` | `C:/Users/Owner/.config/git/ignore` | `~/.config/git/ignore` |
| `autocrlf` | 設定なし | `true` | 設定なし |
| 認証 | `/usr/bin/gh` | `GitHub CLI (Windows)` | `/opt/homebrew/bin/gh` |
| SSH→HTTPS 書き換え | あり | なし | あり |

## ~/.config/git/ignore

全リポジトリ共通で無視するファイルのパターン。

| パターン | 説明 |
|---------|------|
| `**/.claude/settings.local.json` | Claude Code のローカル設定 |

## ~/.config/starship.toml

[Starship](https://starship.rs/) プロンプトのテーマ設定。青系のパワーラインスタイル。

**左プロンプト（4 セグメント）:**

| セグメント | 背景色 | 内容 |
|-----------|--------|------|
| ユーザー名 | `#4C72B0`（ダークブルー） | 常に表示 |
| ディレクトリ | `#5A9BD4`（ライトブルー） | パスを2階層まで表示、リポジトリルートで切り詰め |
| Git ブランチ | `#2E3440`（Nord ダーク） | ブランチ名 |
| Git ステータス | `#2E3440`（Nord ダーク） | 変更・ahead/behind 状態 |

**右プロンプト:**

- 環境変数 `PS_ENV` の値を `#3A86FF`（ブルー）背景で表示

**入力記号:** 成功時は緑の `❯`、エラー時は赤の `❯`

## ~/.config/mise/config.toml

[mise](https://mise.jdx.dev/) によるランタイムバージョン管理のグローバル設定。

| ツール | バージョン |
|--------|-----------|
| Ruby | 3（最新の 3.x） |

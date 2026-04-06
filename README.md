# dotfiles

[chezmoi](https://chezmoi.io) で管理する設定ファイル群。WSL2 (Ubuntu)、Windows、Mac で共有できる構成。

## 管理ファイル

| ファイル | プラットフォーム |
|---------|----------------|
| `~/.bashrc` | Linux / WSL のみ |
| `~/.profile` | Linux / WSL のみ |
| `~/.gitconfig` | 全OS（テンプレートでOS別に分岐） |
| `~/.config/git/ignore` | 共通 |
| `~/.config/starship.toml` | 共通 |
| `~/.config/mise/config.toml` | 共通 |

各ファイルの詳細は [docs/configurations.md](docs/configurations.md) を参照。

## セットアップ

### chezmoi のインストール

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

### 初回セットアップ（GitHub から）

```sh
chezmoi init --apply https://github.com/axeimk/dotfiles.git
```

### 手動セットアップ

```sh
# リポジトリをクローン
git clone https://github.com/axeimk/dotfiles.git ~/dev/dotfiles

# source directory を指定
mkdir -p ~/.config/chezmoi
echo 'sourceDir = "/home/owner/dev/dotfiles"' > ~/.config/chezmoi/chezmoi.toml

# 適用
chezmoi apply
```

## 日常的な使い方

```sh
# 変更の差分を確認
chezmoi diff

# 変更を適用
chezmoi apply

# ホームのファイルを chezmoi に取り込む
chezmoi add ~/.some_config

# source directory を開く
chezmoi cd
```

## 新しいファイルを追加する

```sh
chezmoi add ~/.config/something
cd ~/dev/dotfiles
git add .
git commit -m "Add something config"
```

テンプレートとして追加する場合（OS別に内容を変えたい場合）:

```sh
chezmoi add --template ~/.some_config
```

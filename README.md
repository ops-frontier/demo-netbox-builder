# demo-netbox-builder

デモ用 NetBox サーバ構築 IaC

さくらのクラウド上に NetBox サーバを構築するための Infrastructure as Code (IaC) プロジェクトです。Terraform でサーバをプロビジョニングし、Ansible で NetBox をインストール・設定します。

## 概要

このプロジェクトは以下の機能を提供します：

- **開発環境**: VSCode DevContainer による一貫した開発環境
- **インフラプロビジョニング**: Terraform によるさくらのクラウドサーバの自動構築
- **アプリケーション構成**: Ansible による NetBox の自動インストールと設定
- **プロキシ対応**: Squid プロキシによるインターネットアクセス（プライベートネットワーク環境向け）

## 前提条件

- GitHub Codespaces または Docker 対応の開発環境
- さくらのクラウドのアカウント
- さくらのクラウドの API アクセストークン

## セットアップ

### 1. 環境変数の設定

GitHub Codespaces のシークレット、または環境変数に以下を設定してください：

```bash
SAKURACLOUD_ACCESS_TOKEN=<your_access_token>
SAKURACLOUD_ACCESS_TOKEN_SECRET=<your_access_token_secret>
SAKURACLOUD_ZONE=is1a  # または is1b, tk1a, tk1v など
INTERNAL_SWITCH_NAME=<your_switch_name>  # 接続先のスイッチ名
INTERNAL_NIC_IP=192.168.1.10/24  # サーバに割り当てる IP アドレス（CIDR 形式）
```

### 2. DevContainer の起動

1. このリポジトリを開く
2. VSCode で "Reopen in Container" を実行
3. `post-create.sh` が自動的に実行され、以下が設定されます：
   - Ansible のインストール
   - SSH 鍵の生成（`.ssh/id_ed25519`）
   - Squid プロキシコンテナの起動
   - Terraform 環境変数の設定

### 3. Terraform によるサーバ構築

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

サーバが作成されると、以下の情報が出力されます：
- サーバ ID
- サーバ名
- 内部 IP アドレス
- SSH 秘密鍵のパス

### 4. Ansible による NetBox インストール

```bash
cd ../ansible

# Ansible コレクションのインストール
ansible-galaxy collection install -r requirements.yml

# プレイブックの実行
ansible-playbook -i inventory.yml playbook.yml
```

インストールが完了すると、以下の情報が表示されます：
- NetBox のアクセス URL
- 初期ログイン情報（ユーザー名: `admin`、パスワード: `admin`）

### 5. NetBox へのアクセス

SSH ポートフォワーディングを使用して NetBox にアクセスします：

```bash
ssh -i ../.ssh/id_ed25519 \
    -L 8080:localhost:80 \
    ubuntu@<INTERNAL_NIC_IP>
```

ブラウザで `http://localhost:8080` にアクセスしてください。

## プロジェクト構成

```
.
├── .devcontainer/
│   ├── devcontainer.json    # DevContainer 設定
│   └── post-create.sh       # 初期セットアップスクリプト
├── terraform/
│   ├── main.tf              # Terraform メイン設定
│   ├── variables.tf         # 変数定義
│   └── outputs.tf           # 出力定義
├── ansible/
│   ├── ansible.cfg          # Ansible 設定
│   ├── inventory.yml        # インベントリ
│   ├── playbook.yml         # メインプレイブック
│   ├── requirements.yml     # 必要な Ansible コレクション
│   └── templates/
│       └── configuration.py.j2  # NetBox 設定テンプレート
├── .gitignore
└── README.md
```

## 機能詳細

### DevContainer

- **ツール**: Terraform, Git, Git-LFS, Python, Docker-in-Docker, Node.js
- **拡張機能**: HashiCorp Terraform, Red Hat Ansible, Python, Claude Code
- **自動セットアップ**: SSH 鍵生成、Squid プロキシ、環境変数設定

### Terraform

- さくらのクラウド上に Ubuntu サーバを構築
- 指定されたスイッチに接続
- 静的 IP アドレスの設定
- SSH 鍵による認証

### Ansible

- プロキシ環境変数の設定（`/etc/environment`）
- PostgreSQL データベースのインストールと設定
- Redis のインストールと設定
- NetBox のインストール（最新版）
- Nginx リバースプロキシの設定
- systemd サービスの設定

### セキュリティに関する注意

- 初期パスワード（`admin`）は必ず変更してください
- `netbox_database_password` と `redis_password` を本番環境用の強力なパスワードに変更してください
- SSH 鍵は `.ssh/` ディレクトリに保存され、Git にコミットされません

## トラブルシューティング

### SSH 接続できない場合

1. サーバの IP アドレスが正しいか確認
2. SSH 鍵のパーミッションを確認: `chmod 600 .ssh/id_ed25519`
3. ネットワーク設定を確認

### Ansible の実行が失敗する場合

1. プロキシが正しく動作しているか確認: `curl -x http://localhost:3128 http://www.google.com`
2. SSH ポートフォワーディングが設定されているか確認
3. インベントリの IP アドレスが正しいか確認

### NetBox にアクセスできない場合

1. SSH ポートフォワーディングが正しく設定されているか確認
2. Nginx が起動しているか確認: `systemctl status nginx`
3. NetBox サービスが起動しているか確認: `systemctl status netbox`

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 参考リンク

- [NetBox Documentation](https://docs.netbox.dev/)
- [Sakura Cloud Documentation](https://manual.sakura.ad.jp/cloud/)
- [Terraform Sakura Cloud Provider](https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs)
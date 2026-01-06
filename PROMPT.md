さくらのクラウド上に netbox のサーバを構築する IaC を開発してください。

## devcontainer
devcontainer.json を作成し、 terraform, git, git-lfs, python, docker-in-dockerをfutures でインストールしてください。post-create.sh を postCreateCommand で起動し、以下を実行してください。ansible と terraform のコードを編集しやすいように拡張モジュールを入れて必要な設定もしてください。Claude Code の拡張モジュールも入れておいてください。
1. ansible をインストール
2.  ed25519 形式の ssh の鍵をプロジェクトの .ssh ディレクトリにオンデマンドに生成（.ssh は gitignore）
3.  構築するサーバがパブリックリポジトリにアクセスするための squid コンテナを
起動（localhost:3128 を listen）
4. terraform から必要な環境変数を参照できるように TF_VAR_{変数名} の環境変数に必要な環境変数を転記（CodeSpaces では環境変数に小文字が使えないため、直接 TF_VAR_ を指定しにくい）
5.  @anthropic-ai/claude-code  をインストールしてください。

## terraform によるサーバの構築
terraform でサーバを起動してください。さくらのクラウドの ubuntu の最新イメージを使用してください。さくらのクラウドの ubuntu のイメージには cloud-init 非対応版と cloud-init 対応版があり、 cloud-init 非対応版では管理者のアカウントが ubuntu 固定になっているので、注意してください。SSH鍵は post-create.sh で作成したものを使用してください。ネットワークは環境変数INTERNAL_SWITCH_NAME
  で指定される名前のスイッチに接続し、環境変数 INTERNAL_NIC_IP
 のアドレス（CIDRフォーマット）を付与してください。 

## ansible による構築
サーバ起動後に ansible でnetboxのサーバを構築してください。ssh の設定でサーバの localhost:3128 をローカルで起動している squid にポート転送してください。
最初に /etc/environment にプロキシ環境変数を設定して、他のタスクがパブリックリポジトリにアクセスできるようにしてください。
ansible のコードについては VS Code の警告が出ないようにしてください。
netboxをインストールしてください。データベースなど依存サービスをサーバ内にインストールしてください。
起動後、ssh のポート転送で netbox の Web UI にアクセスします。初期のID、パスワードがわかるようにしてください。
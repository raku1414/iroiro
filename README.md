# juliamo_game_alt.bsdiff

ことのはアムリラートのフォントのカタカナの左上のゴミをとるパッチ

<pre><code>bsdpatch juliamo_game.ttf juliamo_game_alt.bsdiff</code></pre>みたいにして使う

# freedomstar.mmpz

紛うことなきLMMSのクソ曲

# mpvsingle.sh

mpvをシングルインスタンスで起動するスクリプト

# mastodonディレクトリ

ubuntu、centos、archlinuxでmastodonを建てるための自動スクリプト集

inst_dep.shで依存パッケージをインストールする。

init.shでユーザー1:mastodonとユーザー2:mastodonxを作って
/opt/mstdn以下にnvmとrbenvを使ってmastodonユーザーローカルにnodejs、rubyをインストールしたりmastodonを入れたりする。

systemd_and_nginx_config.shでsystemdの起動スクリプトとnginxの/etc/nginx/conf.d/nginx_mastodon.confを作ったりする。

create_env_production.shで必要なKEYを埋める。

後はenv.productionの必要な部分を埋めて(mailとか)postgresqlでmastodonユーザーとデーターベースを作って、pgheroのための拡張を噛ませて、sudo systemctl start nvinx redis postgresqlしてとかも自動しようと思ったが、postgresqlの設定や置き場所がOSごとに違うというクソに直面して面倒になってましまろです。site:qita.comとかで検索すれば出てきます。もう少ししたら例外処理のない全自動ならできるかもしれないです。

ただinst_dep.shだけは個人的にはそれなりに価値のあるものじゃないかと思うのでどうぞご活用ください。

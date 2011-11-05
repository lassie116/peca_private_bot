peercastの配信の開始と終了を自動投稿するtwitter botスクリプト
=============================================================
peercastのYPを監視して、自分のお気に入り配信名または検索ワードにマッチした配信の開始と終了をtwitterに投稿するスクリプトです。あくまで自分専用のbotとして作ったので公開twitterアカウントに自動投稿するにはあまり向かないと思います。

動作環境
--------
ruby1.9系で動くはず。twitterライブラリ、pitライブラリも必須です。rubygemsでインストールしてください。
また、twitterに自動投稿するためのtwitterAPIの4つのキー("Consumer key","Consumer secret","OAuth token","OAuth token secret")も必要です。どこかで調べて取得しておいてください。


使い方
------
favlist.txtに配信名そのもの、filter.txtにひっかけたい検索ワードを記述してpecapb.rbを起動してください。四つのキーを登録すれば、10分おきにyplist.txtにあるYPをチェックして、配信名もしくは検索ワードにマッチした配信の開始と終了をtwitterに投稿します。
止まる機能はありません。適当に止めてください。

注意
----
peercast本体の機能はないので、peercastが動作しているマシンからでないと(多分)まともに動きません。

経緯など
--------
starryskylogicさんのPecaShogi_bot( https://github.com/starryskylogic/PecaShogi_bot )を見て、便利そうだったので機能をまるパクりしました。ありがとうございます。

おといあわせ
------------
twitter @lass1e
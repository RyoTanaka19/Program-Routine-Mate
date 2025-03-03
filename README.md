## ▪️ サービス概要

「Program Routine Mate」はプログラミング学習を共有しながら楽しく習慣化をサポートするアプリです。

ユーザー同士の記録をを共有できます。

また、1 つ習慣化したら、他の学習に挑戦できます。

## ▪️ このサービスへの思い・作りたい理由

私は、未経験から 2 年間ほど IT 業界に従事してました。

IT 業界の SES エンジニアをしているときは、黙々と個人で業務に必要なプログラミング学習をしていました。  
その後、退職して RUNTEQ というプログラミング   スクールに入学しました。

このスクールは、とてもコミュニティーが盛んであり、
Mattermost や Discode というコミュニケーションサービスを使って  
他の人の頑張りを見たり、記録を共有することで
黙々と学習していた時よりも学習が捗り、楽しくプログラミング学習を今でも続けられております。

卒業後も上記のような環境で学習を継続したいと
同時に RUNTEQ 生以外の人たちとも学習を共有したいなと思い始めるようになり、

上記のアプリの制作を始めました。

## ▪️ ターゲットとなるユーザー層

- プログラミング学習を始めたばかりの人
  - (習慣化を目的としているので、プログラミング学習を始めたがなかなか続かない人)
  - (他の人の学習記録を見ることでどうやって学習しているか(どんな書籍や Udemy を使っているかやアウトプットの仕方を参考にできる)
  - また、初学者で 1 つずつプログラミング学習を習慣にしていきたい人にもおすすめである
  - プログラミング学習は、本当にやるべき学習がたくさんあります。
    - (例 プログラミング言語(Ruby など)、フレームワーク(RubyonRails など)、HTML、CSS、JavaScript、SQL、git、 Docker などそれ以上にまだまだ、たくさんあります。
  - 初学者がいきなり一気に上記の学習を行うとプログラミング学習が続かなくなる可能性が考えられるので、
  - 3 週間(習慣化するには、3 週間かかると言われるので)で 1 つずつ、学習して習慣化したい人にもオススメの Web アプリサービスになります

## ▪️ サービスの利用イメージ

- ユーザーは新しく始めたい取り組みを 1 つ指定します
- その取り組みの期日を指定します(曜日と時間の指定)
- 記録を取り、他のユーザーと共有できる(画像を載せたり、いいねやコメントできる)
- 通知(その期日・時間帯になったら通知)
- 取り組み日数のランキング機能
- ジャンル・学習内容検索(学習したいことが見つからなくなった時、他の人の取り組みを検索して他の学習したいことを探す)

- 新しい取り組みを追加したい場合、

  - 3 週間(21 日)ごとに新しい取り組みを追加できる
  - (例 Ruby を学習する場合、21 日分の記録を確認できれば  SQL の学習を追加など   次の取り組みを追加できる)
  - (習慣化には、3 週間必要だと言われているから)
  - (手を広げると習慣作りが難しくなる可能性があるから 3 セットまで)

- 習慣が続くとバッジがもらえる(3 日坊主回避やそのジャンルのバッジがもらえるなど)
  - (例 プログラミングの Ruby 言語勉強した場合、 Ruby のバッジがもらえるなど)
- AI 機能搭載

  - (本日の調子が悪く学習の取り組む気になれない時に AI に相談できる) → MVPリリース後、自身が考えた学習取り組みをAIに相談して、さらに良いアドバイスをもらいたいと検討している。

- ユーザーが現在ログインしてるかなどを見える化する(Mattermost、discordのようなイメージ)

## ▪️ ユーザーの獲得・宣伝方法

- X による宣伝
- ソーシャルポートフォリオへの掲載
- 自身の times に掲載
- SNS シェアボタン

## ▪️ サービスの差別化ポイント・推しポイント

- 3 週間(21 日)ごとに新しい取り組みを追加できる。

  - 習慣には、3 週間かかると言われているので、まず、1 つを指定して 21 日間学習記録を確認できれば、次の取り組みを追加できるようにすることで、手を広げすぎて学習捗らないというリスクを防げる

- バッジがもらえる  (続けたジャンルはのバッジがもらえるなどのコレクションを楽しむことができる)

- AI 機能  (学習に躓いたり、メンタルが落ち込んでる時に AI に励ましてもらえる  ) → MVPリリース後、自身が考えた学習取り組みをAIに相談して、さらに良いアドバイスをもらいたいに変更したいと検討している。

## ▪️ 機能候補

### MVP リリース時に作っていたいもの

- ユーザー登録機能
- ログイン機能
- ログアウト機能
- 投稿の CRUD（登録・参照・更新・削除）機能
- 画像アップロード
- コメント機能（非 ajax）

### MVP リリース後に作っていたいもの

- 3 週間(21 日)ごとに新しい取り組みを追加できるように設定
- ジャンル・期日・時刻を指定(バッジを集めることができる)
- バッジを集めて、管理できるように設定
- ユーザーが現在ログイン中などと見える化の設定
- 即日通知機能
- ページネーション
- 検索機能
- パスワードリセット
- プロフィール
- いいね機能
- カレンダー機能
- お悩み相談(OpenAPI) → MVPリリース後、自身が考えた学習取り組みをAIに相談して、さらに良いアドバイスをもらいたい変更したいと検討している。
- ランキング機能(継続日数)
- 使い方
- お問い合わせ
- 利用規約
- プライバシーポリシー
- SNS シェアボタン

## 機能の実装方針予定

- バックエンド: Ruby on Rails
- フロントエンド: Daisy UI、Tailwind CSS
- render :PostgreSql

- 高度機能
- 即日通知機能
- ActionCable（Rails 標準）を使う予定
  - 詳細(追加)
  - その期日、時間になったらメールで通知をユーザーに送るイメージです
- OpenAI API 使用予定
  - 詳細(追加)
    - ビジネス用途で考えてないので
    - 無料プランを使うつもりであり、リクエスト頻度が多ければ有料プランに変更する場合もある。

## 画面遷移図
Figma: https://www.figma.com/design/l76ZQiTKnKvVSaeN2Gx7GI/Program-Routin-Mate-%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0-1&p=f&t=WXJwUnWwraNNPRDn-0
## ER図
[![Image from Gyazo](https://i.gyazo.com/de626449e6b92c2666d3aa8374e92281.png)](https://gyazo.com/de626449e6b92c2666d3aa8374e92281)

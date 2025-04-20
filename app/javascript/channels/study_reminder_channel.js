import consumer from './consumer';

// 'StudyReminderChannel' に接続して、リアルタイム通知を受け取るための設定
consumer.subscriptions.create('StudyReminderChannel', {
  // チャンネルへの接続が成功したときに呼ばれるメソッド
  connected() {
    console.log('Connected to StudyReminderChannel');
  },

  // チャンネルから切断されたときに呼ばれるメソッド
  disconnected() {
    console.log('Disconnected from StudyReminderChannel');
  },

  // チャンネルから受信したデータを処理するメソッド
  received(data) {
    // 受信した通知メッセージを表示するエリアを取得
    const notificationArea = document.getElementById('notification-area');

    // 新しい通知を作成
    const notification = document.createElement('div');

    // 通知のスタイルを設定
    notification.style.backgroundColor = 'lightblue'; // 背景色
    notification.style.padding = '10px'; // パディング
    notification.style.marginBottom = '10px'; // 下のマージン
    notification.style.borderRadius = '5px'; // 角を丸く
    notification.style.boxShadow = '0px 4px 6px rgba(0, 0, 0, 0.1)'; // 影を付けて立体感を出す
    notification.innerText = data.message; // 受け取ったメッセージを通知として設定

    // 作成した通知を通知エリアに追加
    notificationArea.appendChild(notification);

    // 通知数を更新する処理
    const notificationCount = document.getElementById('notification-count');
    let currentCount = parseInt(notificationCount.innerText); // 現在の通知数を取得
    notificationCount.innerText = currentCount + 1; // 通知数を1つ増やす

    // 通知アイコンがクリックされたときに通知エリアの表示・非表示を切り替えるイベントを登録
    const notificationIcon = document.getElementById('notification-icon');

    // アイコンが一度もクリックされていない場合のみイベントを追加
    if (!notificationIcon.hasAttribute('data-clicked')) {
      notificationIcon.setAttribute('data-clicked', 'true'); // アイコンがクリックされたことを記録

      // 通知アイコンがクリックされたときに通知エリアの表示をトグルする
      notificationIcon.addEventListener('click', function () {
        const notificationArea = document.getElementById('notification-area');
        // 通知エリアの表示・非表示を切り替え
        notificationArea.style.display =
          notificationArea.style.display === 'none' ? 'block' : 'none';
      });
    }

    // 通知がクリックされた場合、その通知を非表示にする
    notification.addEventListener('click', function () {
      notification.style.display = 'none'; // クリックされた通知を非表示にする
      // 通知数を更新（通知数がマイナスにならないように処理）
      let currentCount = parseInt(notificationCount.innerText);
      if (currentCount > 0) {
        notificationCount.innerText = currentCount - 1; // 通知数を1つ減らす
      }
    });
  },
});

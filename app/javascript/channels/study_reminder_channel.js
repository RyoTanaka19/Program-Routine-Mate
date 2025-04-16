import consumer from './consumer';

consumer.subscriptions.create('StudyReminderChannel', {
  connected() {
    console.log('Connected to StudyReminderChannel');
  },

  disconnected() {
    console.log('Disconnected from StudyReminderChannel');
  },

  received(data) {
    // 通知のメッセージを作成
    const notificationArea = document.getElementById('notification-area');
    const notification = document.createElement('div');
    notification.style.backgroundColor = 'lightblue';
    notification.style.padding = '10px';
    notification.style.marginBottom = '10px';
    notification.style.borderRadius = '5px';
    notification.style.boxShadow = '0px 4px 6px rgba(0, 0, 0, 0.1)';
    notification.innerText = data.message;

    // 通知エリアに追加
    notificationArea.appendChild(notification);

    // 通知数を更新
    const notificationCount = document.getElementById('notification-count');
    let currentCount = parseInt(notificationCount.innerText);
    notificationCount.innerText = currentCount + 1;

    // 通知アイコンがクリックされたときのイベントを一度だけ登録
    const notificationIcon = document.getElementById('notification-icon');
    if (!notificationIcon.hasAttribute('data-clicked')) {
      notificationIcon.setAttribute('data-clicked', 'true');

      notificationIcon.addEventListener('click', function () {
        // 通知エリアの表示・非表示をトグル
        const notificationArea = document.getElementById('notification-area');
        notificationArea.style.display =
          notificationArea.style.display === 'none' ? 'block' : 'none';
      });
    }

    // 通知がクリックされたらその通知を消す
    notification.addEventListener('click', function () {
      notification.style.display = 'none'; // クリックされた通知を消す
      // 通知数を更新（マイナスにならないようにチェック）
      let currentCount = parseInt(notificationCount.innerText);
      if (currentCount > 0) {
        notificationCount.innerText = currentCount - 1;
      }
    });
  },
});

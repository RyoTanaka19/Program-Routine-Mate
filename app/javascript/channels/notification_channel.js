import consumer from './consumer';

// 多重購読防止：すでに購読していたらスキップ
if (!window.notificationSubscribed) {
  const userId = document.body.dataset.userId;

  if (!userId) {
    console.warn('User ID not found in data-user-id attribute on <body>');
  } else {
    consumer.subscriptions.create(
      { channel: 'NotificationChannel', user_id: userId }, // ← ここが重要
      {
        connected() {
          console.log(`Connected to NotificationChannel for user ${userId}`);
        },

        disconnected() {
          console.log('Disconnected from NotificationChannel');
        },

        received(data) {
          const notificationArea = document.getElementById('notification-area');
          const notification = document.createElement('div');

          // 通知のスタイル設定
          notification.style.backgroundColor = 'lightblue';
          notification.style.padding = '10px';
          notification.style.marginBottom = '10px';
          notification.style.borderRadius = '5px';
          notification.style.boxShadow = '0px 4px 6px rgba(0, 0, 0, 0.1)';
          notification.innerText = data.message;

          // 通知を追加
          notificationArea.appendChild(notification);

          // 通知数を更新
          const notificationCount =
            document.getElementById('notification-count');
          let currentCount = parseInt(notificationCount.innerText);
          notificationCount.innerText = currentCount + 1;

          // 通知アイコンへのクリックイベントを一度だけ登録
          const notificationIcon = document.getElementById('notification-icon');
          if (!notificationIcon.hasAttribute('data-clicked')) {
            notificationIcon.setAttribute('data-clicked', 'true');
            notificationIcon.addEventListener('click', function () {
              notificationArea.style.display =
                notificationArea.style.display === 'none' ? 'block' : 'none';
            });
          }

          // 通知をクリックしたら非表示＆カウント減らす
          notification.addEventListener('click', function () {
            notification.style.display = 'none';
            let currentCount = parseInt(notificationCount.innerText);
            if (currentCount > 0) {
              notificationCount.innerText = currentCount - 1;
            }
          });
        },
      }
    );

    window.notificationSubscribed = true;
  }
}

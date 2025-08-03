import consumer from './consumer';

// DOM要素キャッシュ
const notificationCountElement = document.getElementById('notification-count');
const notificationAreaElement = document.getElementById('notification-area');
const notificationIconElement = document.getElementById('notification-icon');

// 通知要素を作成する関数（Tailwind CSSクラスを付与）
function createNotificationElement(message) {
  const notification = document.createElement('div');
  notification.className = [
    'bg-blue-200', // 水色背景
    'p-3', // パディング
    'mb-3', // 下マージン
    'rounded-md', // 角丸
    'shadow-md', // 影
    'cursor-pointer',
    'text-blue-900',
    'select-none',
  ].join(' ');
  notification.innerText = message;
  return notification;
}

// 通知数を取得する関数
function getNotificationCount() {
  if (!notificationCountElement) return 0;
  const count = parseInt(notificationCountElement.innerText, 10);
  return isNaN(count) ? 0 : count;
}

// 通知数を更新する関数
function updateNotificationCount(newCount) {
  if (notificationCountElement) notificationCountElement.innerText = newCount;
}

// 通知エリアの表示/非表示を切り替えるクリックイベントを一度だけ登録
function setupNotificationToggle() {
  if (!notificationIconElement || !notificationAreaElement) return;
  if (notificationIconElement.hasAttribute('data-clicked')) return;

  notificationIconElement.setAttribute('data-clicked', 'true');
  notificationIconElement.addEventListener('click', () => {
    if (!notificationAreaElement) return;
    notificationAreaElement.style.display =
      notificationAreaElement.style.display === 'none' ? 'block' : 'none';
  });
}

// 多重購読防止 & 購読開始
if (!window.notificationSubscribed) {
  consumer.subscriptions.create('NotificationChannel', {
    connected() {
      console.log('Connected to NotificationChannel');
      setupNotificationToggle(); // ここで一度だけ登録
    },

    disconnected() {
      console.log('Disconnected from NotificationChannel');
    },

    received(data) {
      if (!notificationAreaElement) return;

      // 通知を作成して追加
      const notification = createNotificationElement(data.message);
      notificationAreaElement.appendChild(notification);

      // 通知数を増やす
      updateNotificationCount(getNotificationCount() + 1);

      // 通知クリックで削除＆通知数減
      notification.addEventListener('click', () => {
        notification.remove();
        const count = getNotificationCount();
        if (count > 0) updateNotificationCount(count - 1);
      });
    },
  });

  window.notificationSubscribed = true;
}

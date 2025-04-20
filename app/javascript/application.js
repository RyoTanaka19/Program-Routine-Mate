// Turboの読み込み：ページ遷移を高速化し、部分的にページを更新する仕組み
import '@hotwired/turbo-rails';

// Stimulusコントローラーの読み込み
import './controllers';

// Action Cableを利用するためのチャネルの読み込み（リアルタイム通信機能用）
import './channels';

// FullCalendarのコア部分をインポート
import { Calendar } from '@fullcalendar/core';
// 月表示などの日付表示プラグインをインポート
import dayGridPlugin from '@fullcalendar/daygrid';
// ユーザーの操作（クリックやドラッグ）を可能にするプラグインをインポート
import interactionPlugin from '@fullcalendar/interaction';

// Turboがページを完全に読み込んだタイミングで実行
document.addEventListener('turbo:load', function () {
  // HTML内にあるID "calendar" の要素を取得
  const calendarEl = document.getElementById('calendar');

  // カレンダー要素が存在するかチェック
  if (calendarEl) {
    // data-events属性に埋め込まれたJSON文字列をパースしてイベントデータに変換
    const eventsData = calendarEl.dataset.events
      ? JSON.parse(calendarEl.dataset.events)
      : [];

    // FullCalendarのインスタンスを作成
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin], // 使用するプラグインを指定
      initialView: 'dayGridMonth', // 初期表示を月ビューに設定
      events: eventsData, // 表示するイベントの配列
      headerToolbar: {
        left: 'prev,next today', // 左側に「前月」「次月」「今日」ボタン
        center: 'title', // 中央にカレンダーのタイトル
        right: 'dayGridMonth,dayGridWeek,dayGridDay', // 右側に表示切替（カレンダーの種類）
      },
      editable: false, // イベントのドラッグなど編集を無効化
      droppable: false, // 外部要素のドロップを無効化
      dayCellClassNames: ['custom-day-cell'], // 各日セルにカスタムクラスを追加

      // 各日セルが描画された後に呼ばれる処理
      dayCellDidMount: function (info) {
        const today = new Date(); // 今日の日付を取得
        const isToday =
          info.date.getDate() === today.getDate() &&
          info.date.getMonth() === today.getMonth() &&
          info.date.getFullYear() === today.getFullYear();

        // 今日の日付のセルにスタイルを適用
        if (isToday) {
          info.el.classList.add(
            'bg-blue-200', // 背景色
            'border', // 境界線
            'border-blue-600', // 青色の枠線
            'rounded-md', // 角を丸く
            'text-gray-900', // テキスト色
            'font-semibold' // テキストを太字
          );
        }
      },

      // イベントをクリックしたときの処理
      eventClick: function (info) {
        alert(
          `イベント: ${info.event.title}\n${info.event.start.toLocaleString()}`
        );
      },

      // イベントにマウスを重ねたときの処理（ツールチップを表示）
      eventMouseEnter: function (info) {
        info.el.setAttribute(
          'title',
          info.event.extendedProps.description || info.event.title
        );
      },
    });

    // カレンダーを画面に表示
    calendar.render();
  } else {
    // 要素が見つからなかった場合のエラー出力
    console.error('カレンダーの要素が見つかりません。');
  }
});

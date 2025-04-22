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
  const calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    const eventsData = calendarEl.dataset.events
      ? JSON.parse(calendarEl.dataset.events)
      : [];

    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      events: eventsData,
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,dayGridWeek,dayGridDay',
      },
      editable: false,
      droppable: false,
      dayCellClassNames: ['custom-day-cell'],

      dayCellDidMount: function (info) {
        const today = new Date();
        const isToday =
          info.date.getDate() === today.getDate() &&
          info.date.getMonth() === today.getMonth() &&
          info.date.getFullYear() === today.getFullYear();

        if (isToday) {
          info.el.classList.add(
            'bg-blue-200',
            'border',
            'border-blue-600',
            'rounded-md',
            'text-gray-900',
            'font-semibold'
          );
        }

        // ✅ セルの高さとパディングをさらに広げ、内容を整列
        info.el.classList.add(
          'py-8', // 上下の余白を広げる
          'min-h-[6rem]', // セルの最小高さを広げる
          'flex', // Flexboxを使用して日付を整列
          'items-center', // セル内で内容を縦方向に中央揃え
          'justify-center', // セル内で内容を横方向に中央揃え
          'text-lg', // テキストサイズを少し大きく
          'text-gray-700' // 見やすい色に設定
        );
      },

      eventClick: function (info) {
        alert(
          `イベント: ${info.event.title}\n${info.event.start.toLocaleString()}`
        );
      },

      eventMouseEnter: function (info) {
        info.el.setAttribute(
          'title',
          info.event.extendedProps.description || info.event.title
        );
      },
    });

    calendar.render();
  } else {
    console.error('カレンダーの要素が見つかりません。');
  }
});

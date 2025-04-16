import '@hotwired/turbo-rails';
import './controllers';
import './channels';

import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

document.addEventListener('turbo:load', function () {
  const calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      events: calendarEvents,
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: '',
      },
      editable: false,
      droppable: false,

      dayCellClassNames: ['custom-day-cell'],

      dayCellDidMount: function (info) {
        const today = new Date();
        if (
          info.date.getDate() === today.getDate() &&
          info.date.getMonth() === today.getMonth() &&
          info.date.getFullYear() === today.getFullYear()
        ) {
          info.el.classList.add('bg-blue-500', 'text-white');
        }
      },
    });

    calendar.render();

    const addEventToCalendar = function (newEvent) {
      calendar.addEvent(newEvent);
      calendar.refetchEvents();
    };

    addEventToCalendar({
      title: '新しい学習セッション',
      start: '2025-04-15T10:00:00',
      end: '2025-04-15T12:00:00',
      description: 'この日は新しい学習セッションが開始されました。',
    });
  } else {
    console.error('カレンダーの要素が見つかりません。');
  }
});

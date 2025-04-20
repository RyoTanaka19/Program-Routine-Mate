import '@hotwired/turbo-rails';
import './controllers';
import './channels';

import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

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

import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('ajax:success', (event) => {
      const [data, status, xhr] = event.detail;
      if (data.status === 'success') {
        window.location.href = data.redirect_url;
      }
    });

    this.element.addEventListener('ajax:error', (event) => {
      alert('リマインダーの作成に失敗しました。');
    });
  }
}

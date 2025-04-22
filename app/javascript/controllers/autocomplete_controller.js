import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static values = { url: String };
  static targets = ['results', 'genre'];

  search(event) {
    const query = encodeURIComponent(event.target.value);
    const genre = encodeURIComponent(this.genreTarget.value);
    const url = `${this.urlValue}?q[content_cont]=${query}&q[study_genre_name_eq]=${genre}`;

    fetch(url)
      .then((response) => response.json())
      .then((data) => this.updateResults(data))
      .catch((error) => {
        console.error('Error fetching autocomplete data:', error);
        this.showError();
      });
  }

  updateResults(data) {
    this.resultsTarget.innerHTML = '';

    if (data.length === 0) {
      this.showNoResultsMessage();
      return;
    }

    data.forEach((item) => {
      const li = document.createElement('li');
      li.textContent = item.content;
      li.classList.add('cursor-pointer', 'hover:bg-blue-100', 'px-4', 'py-2');

      li.addEventListener('click', () => {
        this.selectResult(item);
      });

      this.resultsTarget.appendChild(li);
    });
  }

  selectResult(item) {
    const input = this.element.querySelector('input');
    input.value = item.content;
    this.resultsTarget.innerHTML = '';
  }

  showNoResultsMessage() {
    const message = document.createElement('li');
    message.textContent = '該当する結果はありません。';
    message.classList.add('text-gray-500', 'px-4', 'py-2');
    this.resultsTarget.appendChild(message);
  }

  showError() {
    const message = document.createElement('li');
    message.textContent =
      'データの取得に失敗しました。もう一度お試しください。';
    message.classList.add('text-red-500', 'px-4', 'py-2');
    this.resultsTarget.appendChild(message);
  }

  resetSearch() {
    const input = this.element.querySelector('input');
    if (input) input.value = '';
    this.resultsTarget.innerHTML = '';
  }
}

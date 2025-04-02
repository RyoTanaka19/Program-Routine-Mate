// app/javascript/controllers/autocomplete_controller.js
import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static values = { url: String };
  static targets = ['results'];

  search(event) {
    const query = encodeURIComponent(event.target.value);
    const url = `${this.urlValue}?q[content_cont]=${query}`;

    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        this.updateResults(data);
      })
      .catch((error) =>
        console.error('Error fetching autocomplete data:', error)
      );
  }

  updateResults(data) {
    this.resultsTarget.innerHTML = '';

    data.forEach((item) => {
      const li = document.createElement('li');
      li.textContent = item.content;
      li.addEventListener('click', () => {
        this.selectResult(item);
      });
      this.resultsTarget.appendChild(li);
    });
  }

  selectResult(item) {
    this.element.querySelector('input').value = item.content;

    this.resultsTarget.innerHTML = '';
  }
}

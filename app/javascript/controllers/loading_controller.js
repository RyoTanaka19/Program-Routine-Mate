import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['spinner'];
  connect() {
    this.hide();
  }
  show() {
    this.spinnerTarget.classList.remove('hidden');
  }
  hide() {
    this.spinnerTarget.classList.add('hidden');
  }
}

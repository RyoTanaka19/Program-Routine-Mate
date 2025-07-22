// app/javascript/controllers/friend_add_modal_controller.js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['modal', 'message'];

  openModal() {
    this.modalTarget.classList.remove('hidden');
    this.messageTarget.classList.remove('hidden');

    // アニメーションのリセット
    this.messageTarget.classList.remove('animate-fade-in');
    void this.messageTarget.offsetWidth;
    this.messageTarget.classList.add('animate-fade-in');
  }

  closeModal() {
    this.modalTarget.classList.add('hidden');
  }

  clickOutside(event) {
    if (event.target === this.modalTarget) {
      this.closeModal();
    }
  }
}

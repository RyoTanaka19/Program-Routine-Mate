import { Controller } from '@hotwired/stimulus';

// このクラスは、オートコンプリート機能を提供するために使用されます。
// ユーザーが検索した内容に基づいて、APIを呼び出して結果を表示します。
export default class extends Controller {
  // このコントローラーで使われるURLを格納するための値と、DOM要素のターゲットを定義
  static values = { url: String }; // URLを格納するための値
  static targets = ['results', 'genre']; // 検索結果とジャンルのターゲットを定義

  // 検索イベントが発生した際に呼ばれるメソッド
  search(event) {
    // 入力された検索キーワードをエンコード
    const query = encodeURIComponent(event.target.value);
    // 選択されたジャンルをエンコード
    const genre = encodeURIComponent(this.genreTarget.value);
    // APIのURLを構築
    const url = `${this.urlValue}?q[content_cont]=${query}&q[study_genre_name_eq]=${genre}`;

    // APIを呼び出して結果を取得
    fetch(url)
      .then((response) => response.json()) // 結果をJSON形式で処理
      .then((data) => this.updateResults(data)) // 結果を更新
      .catch((error) => {
        console.error('Error fetching autocomplete data:', error); // エラーが発生した場合にログを表示
        this.showError(); // エラーメッセージを表示
      });
  }

  // 取得したデータを表示するメソッド
  updateResults(data) {
    // 結果の表示領域を空にする
    this.resultsTarget.innerHTML = '';

    // 結果がない場合、メッセージを表示
    if (data.length === 0) {
      this.showNoResultsMessage();
      return;
    }

    // 取得したデータをリスト項目として表示
    data.forEach((item) => {
      const li = document.createElement('li'); // 新しいリスト項目を作成
      li.textContent = item.content; // コンテンツをリスト項目に設定
      li.classList.add('cursor-pointer', 'hover:bg-blue-100', 'px-4', 'py-2'); // スタイルを適用

      // リスト項目がクリックされたときに選択されるようにイベントリスナーを設定
      li.addEventListener('click', () => {
        this.selectResult(item);
      });

      // 結果表示領域にリスト項目を追加
      this.resultsTarget.appendChild(li);
    });
  }

  // ユーザーがリスト項目を選択した際に入力欄にその内容を反映させるメソッド
  selectResult(item) {
    const input = this.element.querySelector('input'); // 入力フィールドを取得
    input.value = item.content; // 入力欄に選択された内容を設定
    this.resultsTarget.innerHTML = ''; // 結果表示領域を空にする
  }

  // 検索結果がない場合に表示するメッセージ
  showNoResultsMessage() {
    const message = document.createElement('li'); // 新しいリスト項目を作成
    message.textContent = '該当する結果はありません。'; // メッセージを設定
    message.classList.add('text-gray-500', 'px-4', 'py-2'); // スタイルを適用
    this.resultsTarget.appendChild(message); // 結果表示領域にメッセージを追加
  }

  // エラー発生時に表示するメッセージ
  showError() {
    const message = document.createElement('li'); // 新しいリスト項目を作成
    message.textContent =
      'データの取得に失敗しました。もう一度お試しください。'; // エラーメッセージを設定
    message.classList.add('text-red-500', 'px-4', 'py-2'); // エラー用のスタイルを適用
    this.resultsTarget.appendChild(message); // 結果表示領域にエラーメッセージを追加
  }

  // 検索をリセットするメソッド
  resetSearch() {
    const input = this.element.querySelector('input'); // 入力フィールドを取得
    if (input) input.value = ''; // 入力欄を空にする
    this.resultsTarget.innerHTML = ''; // 結果表示領域を空にする
  }
}

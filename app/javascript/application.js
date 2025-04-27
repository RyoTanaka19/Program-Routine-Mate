// Turboの読み込み：ページ遷移を高速化し、部分的にページを更新する仕組み
import '@hotwired/turbo-rails';

// Stimulusコントローラーの読み込み
import './controllers';

// Action Cableを利用するためのチャネルの読み込み（リアルタイム通信機能用）
import './channels';

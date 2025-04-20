// app/javascript/channels/consumer.js

// Action Cable から createConsumer 関数をインポート
// これは WebSocket の接続を管理するための機能です。
import { createConsumer } from '@rails/actioncable';

// 開発環境やローカル環境では、デフォルト設定での consumer をエクスポートします。
// この export は他のファイル（例: chat_channel.js など）で利用されます。
export default createConsumer();

// ※以下のコードは追加の WebSocket 接続設定を行っていますが、実は無効に終わっている状態です。
// `cable` という変数に接続を格納しているだけで、export も使用もしていません。
const cable = createConsumer('wss://program-routine-mate.com/cable');

// ↑補足：もし本番環境用に明示的な URL を指定して WebSocket 接続したい場合、
// 上記の `cable` を export する、または上の `default createConsumer()` を書き換える必要があります。

// 例えば以下のように書くと、本番環境の URL を使うようになります：
// export default createConsumer('wss://program-routine-mate.com/cable');
